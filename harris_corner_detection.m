% Load an image
I = imread('real_mad.jpg');
I_gray = rgb2gray(I); % Convert to grayscale if necessary

% Parameters
sigma = 1.5; % Standard deviation for Gaussian filter
threshold = 0.01; % Threshold for lambda_min
window_size = 3; % Size of the window for non-maximum suppression

% Compute gradients
[Ix, Iy] = imgradientxy(I_gray, 'sobel');
    
% Compute products of gradients
Ix2 = imgaussfilt(Ix.^2, sigma);
Iy2 = imgaussfilt(Iy.^2, sigma);
Ixy = imgaussfilt(Ix .* Iy, sigma);

% Initialize lambda_min
lambda_min = zeros(size(I_gray));

% Compute lambda_min for each pixel
for i = 1:size(I_gray, 1)
    for j = 1:size(I_gray, 2)
        % Construct the H matrix
        H = [Ix2(i, j) Ixy(i, j); Ixy(i, j) Iy2(i, j)];
        
        % Compute the eigenvalues of H
        eig_vals = eig(H);
        
        % Store the minimum eigenvalue
        lambda_min(i, j) = min(eig_vals);
    end
end

% Normalize lambda_min
lambda_min = lambda_min / max(lambda_min(:));

% Apply threshold
corner_peaks = lambda_min > threshold;

% Non-maximum suppression
nms_corners = zeros(size(lambda_min));
for i = 2:size(lambda_min, 1) - 1
    for j = 2:size(lambda_min, 2) - 1
        if corner_peaks(i, j)
            % Get the neighborhood
            window = lambda_min(i-1:i+1, j-1:j+1);
            if lambda_min(i, j) == max(window(:))
                nms_corners(i, j) = 1;
            end
        end
    end
end

% Find the coordinates of the corner points
[r, c] = find(nms_corners);

% Create a figure and axes
figure;

% Display the original image
subplot(1, 2, 1);
imshow(I);
title('Original Image');

% Display the image with corners marked
subplot(1, 2, 2);
imshow(I); hold on;
plot(c, r, 'g+');
title('Image with Harris Corners');
hold off;
