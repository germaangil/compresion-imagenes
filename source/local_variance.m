function [low_variance_images, high_variance_images, variances] = local_variance(image_files)
    % local_variance_coefs_no_toolbox - Calcula la varianza local promedio
    % de un conjunto de imágenes.
    %
    % Inputs:
    %   image_files - Celda con las rutas de las imágenes (formato .bmp o similar).
    %
    % Outputs:
    %   low_variance_images - Nombres de las 5 imágenes con menor varianza local promedio.
    %   high_variance_images - Nombres de las 5 imágenes con mayor varianza local promedio.
    %   variances - Vector con las varianzas locales promedio calculadas para todas las imágenes.
    
    % Inicializar vector de varianzas locales promedio
    variances = zeros(1, length(image_files));
    
    % Tamaño de la ventana para la varianza local (ejemplo: 3x3)
    window_size = 3;
    half_window = floor(window_size / 2);
    
    % Crear un filtro de promedio para la convolución
    avg_filter = ones(window_size) / (window_size^2);
    
    % Calcular la varianza local promedio para cada imagen
    for i = 1:length(image_files)
        % Leer la imagen
        img = imread(image_files{i});
        % Convertir a escala de grises si es necesario
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        img = double(img); % Convertir a double para cálculos

        % Calcular el promedio local
        local_mean = conv2(img, avg_filter, 'same');
        % Calcular el promedio de los cuadrados
        local_mean_sq = conv2(img.^2, avg_filter, 'same');
        % Calcular la varianza local (E[x^2] - (E[x])^2)
        local_variance = local_mean_sq - local_mean.^2;
        
        % Calcular la media de las varianzas locales
        variances(i) = mean(local_variance(:));
    end

    % Ordenar imágenes por varianza local promedio
    [~, sorted_indices] = sort(variances);
    
    % Seleccionar 5 imágenes con baja varianza local promedio y 5 con alta varianza local promedio
    low_variance_images = image_files(sorted_indices(1:5)) % Baja varianza local
    high_variance_images = image_files(sorted_indices(end-4:end)) % Alta varianza local
end
