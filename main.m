% Load images
cover = imread('lena.png');
watermark = imread('copyright.png');

% Convert images to double
cover = im2double(cover);
watermark = im2double(watermark);

% Check if images are color and keep only the first three layers if they are
if size(cover, 3) > 1
    cover = cover(:,:,1:3);
end

% Convert watermark to grayscale if it is not
if size(watermark, 3) ~= 1
    watermark = rgb2gray(watermark);
end

% Resize watermark to match the size of cover
watermark = imresize(watermark, [size(cover, 1), size(cover, 2)]);

% Pad images to nearest multiple of 2^3
padSize = 2^3;
cover = padarray(cover, mod(padSize - size(cover), padSize), 'post');
watermark = padarray(watermark, mod(padSize - size(watermark), padSize), 'post');

% Apply 3-level wavelet transform to the cover image
[cover_LL, cover_LH, cover_HL, cover_HH] = dwt2(cover, 'db1');
[cover_LL2, cover_LH2, cover_HL2, cover_HH2] = dwt2(cover_LL, 'db1');
[cover_LL3, cover_LH3, cover_HL3, cover_HH3] = dwt2(cover_LL2, 'db1');

% Apply 3-level wavelet transform to the watermark image
[watermark_LL, watermark_LH, watermark_HL, watermark_HH] = dwt2(watermark, 'db1');
[watermark_LL2, watermark_LH2, watermark_HL2, watermark_HH2] = dwt2(watermark_LL, 'db1');
[watermark_LL3, watermark_LH3, watermark_HL3, watermark_HH3] = dwt2(watermark_LL2, 'db1');

% Hide watermark
k_values = [0.2, 0.6, 1, 1.4, 1.8];
q_values = [0.009, 0.01];

for k = k_values
    for q = q_values
        new_LL3 = k * cover_LL3 + q * watermark_LL3;

        % Reconstruct watermarked image
        watermarked_LL2 = idwt2(new_LL3, cover_LH3, cover_HL3, cover_HH3, 'db1');
        watermarked_LL = idwt2(watermarked_LL2, cover_LH2, cover_HL2, cover_HH2, 'db1');
        watermarked = idwt2(watermarked_LL, cover_LH, cover_HL, cover_HH, 'db1');

        
        % Resize watermarked to match the size of cover
        watermarked = imresize(watermarked, [size(cover, 1), size(cover, 2)]);

        % Calculate MSE and PSNR
        mse = immse(cover, watermarked);
        psnr = 10 * log10(1 / mse);

        fprintf('For k = %.1f and q = %.3f, MSE = %.2f and PSNR = %.2f dB\n', k, q, mse, psnr);

        % Extract watermark
        extracted_LL3 = (new_LL3 - k * cover_LL3) / q;

        % Reconstruct watermark image
        extracted_LL2 = idwt2(extracted_LL3, watermark_LH3, watermark_HL3, watermark_HH3, 'db1');
        extracted_LL = idwt2(extracted_LL2, watermark_LH2, watermark_HL2, watermark_HH2, 'db1');
        extracted_LL = idwt2(extracted_LL, watermark_LH, watermark_HL, watermark_HH, 'db1');
        extracted = idwt2(extracted_LL, [], [], [], 'db1');

        % Resize extracted to match the size of watermark
        extracted = imresize(extracted, [size(watermark, 1), size(watermark, 2)]);

        % Calculate MSE and PSNR for the extracted watermark
        mse = immse(watermark, extracted);
        psnr = 10 * log10(1 / mse);

        fprintf('For the extracted watermark with k = %.1f and q = %.3f, MSE = %.2f and PSNR = %.2f dB\n', k, q, mse, psnr);

        % Display watermarked and extracted images
        figure; % Create a new figure for each image
        imshow(watermarked);
        title(['Watermarked Image for k = ', num2str(k), ' and q = ', num2str(q)]);
        saveas(gcf, ['watermarked_k_', num2str(k), '_q_', num2str(q), '.png']); % Save the figure

        figure; % Create a new figure for each image
        imshow(extracted);
        title(['Extracted Watermark for k = ', num2str(k), ' and q = ', num2str(q)]);
        saveas(gcf, ['extracted_k_', num2str(k), '_q_', num2str(q), '.png']); % Save the figure

        % Apply attacks
        attacked_images = {meanAttack(cover), medianAttack(cover), noiseAttack(cover), shearAttack(cover)};

        for i = 1:length(attacked_images)
            attacked = attacked_images{i};

            % Resize attacked to match the size of cover
            attacked = imresize(attacked, [size(cover, 1), size(cover, 2)]);

            % Apply 3-level wavelet transform to attacked image
            [attacked_LL, attacked_LH, attacked_HL, attacked_HH] = dwt2(attacked, 'db1');
            [attacked_LL2, attacked_LH2, attacked_HL2, attacked_HH2] = dwt2(attacked_LL, 'db1');
            [attacked_LL3, attacked_LH3, attacked_HL3, attacked_HH3] = dwt2(attacked_LL2, 'db1');

            % Extract watermark from attacked image
            extracted_LL3 = (attacked_LL3 - k * cover_LL3) / q;
            extracted = idwt2(extracted_LL3, watermark_LH3, watermark_HL3, watermark_HH3, 'db1');

            % Resize extracted to match the size of watermark
            extracted = imresize(extracted, [size(watermark, 1), size(watermark, 2)]);

            % Calculate MSE and PSNR for the extracted watermark
            mse = immse(watermark, extracted);
            psnr = 10 * log10(1 / mse);

            fprintf('For the extracted watermark from attacked image %d with k = %.1f and q = %.3f, MSE = %.2f and PSNR = %.2f dB\n', i, k, q, mse, psnr);

            % Display attacked and extracted images
            figure; % Create a new figure for each image
            imshow(attacked);
            title(['Attacked Image ', num2str(i), ' for k = ', num2str(k), ' and q = ', num2str(q)]);
            saveas(gcf, ['attacked_', num2str(i), '_k_', num2str(k), '_q_', num2str(q), '.png']); % Save the figure

            figure; % Create a new figure for each image
            imshow(extracted);
            title(['Extracted Watermark from Attacked Image ', num2str(i), ' for k = ', num2str(k), ' and q = ', num2str(q)]);
            saveas(gcf, ['extracted_from_attacked_', num2str(i), '_k_', num2str(k), '_q_', num2str(q), '.png']); % Save the figure
        end
    end
end

% Attack functions
function attacked = meanAttack(image)
    %Mean Attack
    attacked = imfilter(image, fspecial('average'));
end

function attacked = medianAttack(image)
    %Median Attack
    attacked = zeros(size(image));
    for i = 1:size(image, 3)
        attacked(:,:,i) = medfilt2(image(:,:,i));
    end
end

function attacked = noiseAttack(image)
    %Noise Attack
    noise = randn(size(image)) * 0.05; 
    attacked = image + noise;
end

function attacked = shearAttack(image)
    %Shear Attack
    tform = affine2d([1 0 0; .5 1 0; 0 0 1]); 
    routput = imref2d(size(image));
    attacked = imwarp(image,tform,'OutputView',routput);
end
%% 
