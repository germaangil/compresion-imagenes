function RC= jcom_custom(fname,caliQ)

    % jcom_custom: Compresion de imagenes con tablas Huffman customizadas

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
        disp('Funcion jcom_custom:');
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

    % Codifica los tres scans, usando Huffman a medida
    [CodedY, CodedCb, CodedCr, BITS_Y_DC, HUFFVAL_Y_DC, BITS_Y_AC, HUFFVAL_Y_AC, BITS_C_DC, HUFFVAL_C_DC, BITS_C_AC, HUFFVAL_C_AC] = EncodeScans_custom(XScan);
    
    % Genera nombre archivo comprimido <name>.hud
    [~,name,~] = fileparts(fname);
    nombrecomp=strcat(name, '_caliQ', num2str(caliQ), '.huc');

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

    ulenBITS1=uint8(length(BITS_Y_DC));
    uBITS1=uint8(BITS_Y_DC);
    ulenHUFFVAL1=uint8(length(HUFFVAL_Y_DC));
    uHUFFVAL1=uint8(HUFFVAL_Y_DC);
    
    fwrite(fid,ulenBITS1,'uint8');
    fwrite(fid,uBITS1,'uint8');
    fwrite(fid,ulenHUFFVAL1,'uint8');
    fwrite(fid,uHUFFVAL1,'uint8');
    
    ulenBITS2=uint8(length(BITS_Y_AC));
    uBITS2=uint8(BITS_Y_AC);
    ulenHUFFVAL2=uint8(length(HUFFVAL_Y_AC));
    uHUFFVAL2=uint8(HUFFVAL_Y_AC);
    
    fwrite(fid,ulenBITS2,'uint8');
    fwrite(fid,uBITS2,'uint8');
    fwrite(fid,ulenHUFFVAL2,'uint8');
    fwrite(fid,uHUFFVAL2,'uint8');
    
    ulenBITS3=uint8(length(BITS_C_DC));
    uBITS3=uint8(BITS_C_DC);
    ulenHUFFVAL3=uint8(length(HUFFVAL_C_DC));
    uHUFFVAL3=uint8(HUFFVAL_C_DC);
    
    fwrite(fid,ulenBITS3,'uint8');
    fwrite(fid,uBITS3,'uint8');
    fwrite(fid,ulenHUFFVAL3,'uint8');
    fwrite(fid,uHUFFVAL3,'uint8');
    
    ulenBITS4=uint8(length(BITS_C_AC));
    uBITS4=uint8(BITS_C_AC);
    ulenHUFFVAL4=uint8(length(HUFFVAL_C_AC));
    uHUFFVAL4=uint8(HUFFVAL_C_AC);
    
    fwrite(fid,ulenBITS4,'uint8');
    fwrite(fid,uBITS4,'uint8');
    fwrite(fid,ulenHUFFVAL4,'uint8');
    fwrite(fid,uHUFFVAL4,'uint8');
    
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
        disp('Compresion terminada usando las tablas Huffman customizadas');
        disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
        disp('Terminado jcom_custom');
        disp('--------------------------------------------------');
        disp('--------------------------------------------------');
        disp(['Relación de compresión (RC): ', num2str(RC), '%']);
    end
end
