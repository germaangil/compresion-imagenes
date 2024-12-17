function RC= jcom_dflt(fname,caliQ)

    % jcom_dflt: Compresion de imagenes con tablas Huffman por defecto

    % Entradas:
    %  fname: Un string con nombre de archivo, incluido sufijo
    %         Admite BMP y JPEG, indexado y truecolor
    %  caliQ: Factor de calidad (entero positivo >= 1)
    %         100: calidad estandar
    %         >100: menor calidad
    %         <100: mayor calidad
    % Salidas:
    %  RC : relacion de compresion
    %  Genera y almacena un archivo comprimido *.hud

    disptext=1; % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion jcom_dflt:');
    end

    % Instante inicial
    tc=cputime;

    % Lee archivo de imagen
    % Convierte a espacio de color YCbCr
    % Amplia dimensiones a multiplos de 8
    %  X: Matriz original de la imagen en espacio RGB
    %  Xamp: Matriz ampliada de la imagen en espacio YCbCr
    [X, Xamp, tipo, m, n, mamp, namp, TO]=imlee(fname);

    % Calcula DCT bidimensional en bloques de 8 x 8 pixeles
    Xtrans = imdct(Xamp);

    % Cuantizacion de coeficientes
    Xlab=quantmat(Xtrans, caliQ);

    % Genera un scan por cada componente de color
    %  Cada scan es una matriz mamp x namp
    %  Cada bloque se reordena en zigzag
    XScan=scan(Xlab);

    % Codifica los tres scans, usando Huffman por defecto
    [CodedY,CodedCb,CodedCr]=EncodeScans_dflt(XScan);

    % Genera nombre archivo comprimido <name>.hud
    [~,name,~] = fileparts(fname);
    nombrecomp=strcat(name, '_caliQ', num2str(caliQ), '.hud');

    % Abre el archivo para escribir los datos comprimidos
    fid = fopen(nombrecomp, 'w');

    if fid == -1
        error('No se pudo abrir el archivo para escritura');
    end

    % Escribe los datos comprimidos en el archivo .hud
    
    % Escribir las dimensiones de la imagen original y ampliada
    fwrite(fid, uint32(m), 'uint32');    % Dimensión m
    fwrite(fid, uint32(n), 'uint32');    % Dimensión n
    fwrite(fid, uint32(mamp), 'uint32'); % Dimensión amplificada m
    fwrite(fid, uint32(namp), 'uint32'); % Dimensión amplificada n

    % Escribir el valor de caliQ
    fwrite(fid, uint32(caliQ), 'uint32');
    
    % Escribir las longitudes y los datos comprimidos para los tres componentes (Y, Cb, Cr)
    [sbytes1, ultl1]=bits2bytes(CodedY);
    fwrite(fid, uint32(length(sbytes1)), 'uint32');  % Longitud de CodedY
    fwrite(fid, uint8(ultl1),'uint8');
    fwrite(fid, sbytes1, 'uint8');            % Datos de CodedY

    [sbytes2, ultl2]=bits2bytes(CodedCb);
    fwrite(fid, uint32(length(sbytes2)), 'uint32'); % Longitud de CodedCb
    fwrite(fid,uint8(ultl2),'uint8');
    fwrite(fid, sbytes2, 'uint8');           % Datos de CodedCb

    [sbytes3, ultl3]=bits2bytes(CodedCr);
    fwrite(fid, uint32(length(sbytes3)), 'uint32'); % Longitud de CodedCr
    fwrite(fid, uint8(ultl3),'uint8');
    fwrite(fid, sbytes3, 'uint8');           % Datos de CodedCr

    % Cierra el archivo
    fclose(fid);

    disp('Archivo comprimido guardado exitosamente en:');
    disp(nombrecomp);

    % Calculo de la relación de compresión (RC)  
    fileInfo = dir(nombrecomp);  % Obtiene la información del archivo
    TC = fileInfo.bytes;  % Tamaño del archivo comprimido en bytes

    % Calcular la relación de compresión (RC)
    RC = 100 * (TO - TC) / TO;

    % Tiempo de ejecucion
    e=cputime-tc;

    if disptext
        disp('Compresion terminada usando las tablas Huffman por defecto');
        disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
        disp('Terminado jcom_dflt');
        disp('--------------------------------------------------');
        disp('--------------------------------------------------');
        disp(['Relación de compresión (RC): ', num2str(RC), '%']);
    end
end
