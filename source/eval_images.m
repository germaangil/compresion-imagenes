function eval_images(imageArray)
    % eval_images: Analiza la relación entre RC y MSE para distintas imágenes
    % y diferentes factores de calidad en ambos compresores.
    % 
    % Entrada:
    %   - imageArray: Cell array con las rutas de las imágenes en formato BMP.
    % 
    % Salida:
    %   - Gráficos de MSE vs RC para cada imagen.
    %   - Tablas con los resultados correspondientes.
    %   - Gráfica y tabla con promedios de RC y MSE.

    % Factores de calidad a evaluar
    qualityFactors = [100, 250, 500];
    numFactors = length(qualityFactors);
    numImages = length(imageArray);

    % Inicializar matrices para promedios
    RC_avg_dflt = zeros(1, numFactors);
    MSE_avg_dflt = zeros(1, numFactors);
    RC_avg_custom = zeros(1, numFactors);
    MSE_avg_custom = zeros(1, numFactors);

    % Iterar sobre cada imagen del array
    for i = 1:numImages
        imgPath = imageArray{i};
        [~, imgName, ~] = fileparts(imgPath); % Obtener el nombre base de la imagen

        % Inicializar matrices para almacenar resultados
        RC_values_dflt = zeros(1, numFactors);
        MSE_values_dflt = zeros(1, numFactors);
        RC_values_custom = zeros(1, numFactors);
        MSE_values_custom = zeros(1, numFactors);
        
        % Proceso de compresión y descompresión para cada factor de calidad
        for j = 1:numFactors
            caliQ = qualityFactors(j);

            % Llamar a los compresores
            jcom_dflt(imgPath, caliQ);
            jcom_custom(imgPath, caliQ);

            % Generar los nombres de los archivos comprimidos
            compressedPath_dflt = strcat(imgName, '_caliQ', num2str(caliQ), '.hud');
            compressedPath_custom = strcat(imgName, '_caliQ', num2str(caliQ), '.huc');

            % Llamar a los descompresores
            [MSE_dflt, RC_dflt] = jdes_dflt(compressedPath_dflt);
            [MSE_custom, RC_custom] = jdes_custom(compressedPath_custom);

            % Guardar resultados
            RC_values_dflt(j) = RC_dflt;
            MSE_values_dflt(j) = MSE_dflt;
            RC_values_custom(j) = RC_custom;
            MSE_values_custom(j) = MSE_custom;
        end
        
        % Acumular resultados para el promedio
        RC_avg_dflt = RC_avg_dflt + RC_values_dflt;
        MSE_avg_dflt = MSE_avg_dflt + MSE_values_dflt;
        RC_avg_custom = RC_avg_custom + RC_values_custom;
        MSE_avg_custom = MSE_avg_custom + MSE_values_custom;

        % Crear el gráfico para la imagen actual
        figure;
        hold on
        plot(RC_values_dflt, log(MSE_values_dflt), 'r*-.', 'LineWidth', 0.75);
        plot(RC_values_custom, log(MSE_values_custom), 'g*-.', 'LineWidth', 0.75);
        legend('Matlab dflt', 'Matlab custom', 'Location', 'best');
        titulo = [strcat("MSE vs RC para ", imgName, ".bmp"), newline, strcat("Factores de calidad: ", num2str(qualityFactors))];
        title(titulo);
        xlabel('RC(%)');
        ylabel('log(MSE)');
        grid on;

        % Mostrar los resultados en tablas
        resultsTable_dflt = table(qualityFactors', RC_values_dflt', MSE_values_dflt', ...
            'VariableNames', {'Factor_de_Calidad', 'RC', 'MSE'});
        cadena = strcat("Resultados para la imagen ", imgName, " default:");
        disp(cadena);
        disp(resultsTable_dflt);
        
        resultsTable_custom = table(qualityFactors', RC_values_custom', MSE_values_custom', ...
            'VariableNames', {'Factor_de_Calidad', 'RC', 'MSE'});
        cadena = strcat("Resultados para la imagen ", imgName, " custom:");
        disp(cadena);
        disp(resultsTable_custom);
    end

    % Calcular promedios
    RC_avg_dflt = RC_avg_dflt / numImages;
    MSE_avg_dflt = MSE_avg_dflt / numImages;
    RC_avg_custom = RC_avg_custom / numImages;
    MSE_avg_custom = MSE_avg_custom / numImages;

    % Crear gráfica promedio
    figure;
    hold on
    plot(RC_avg_dflt, log(MSE_avg_dflt), 'r*-.', 'LineWidth', 0.75);
    plot(RC_avg_custom, log(MSE_avg_custom), 'g*-.', 'LineWidth', 0.75);
    legend('Matlab dflt promedio', 'Matlab custom promedio', 'Location', 'best');
    title("Promedio de MSE vs RC para todas las imágenes");
    xlabel('RC(%)');
    ylabel('log(MSE)');
    grid on;

    % Mostrar tabla promedio
    avgTable_dflt = table(qualityFactors', RC_avg_dflt', MSE_avg_dflt', ...
        'VariableNames', {'Factor_de_Calidad', 'RC_Promedio', 'MSE_Promedio'});
    disp("Tabla de promedios para el compresor default:");
    disp(avgTable_dflt);

    avgTable_custom = table(qualityFactors', RC_avg_custom', MSE_avg_custom', ...
        'VariableNames', {'Factor_de_Calidad', 'RC_Promedio', 'MSE_Promedio'});
    disp("Tabla de promedios para el compresor custom:");
    disp(avgTable_custom);
end

        