function [MSE, RC] = jdes_custom(fname)
    % jdes_custom: Descompresión de imágenes comprimidas con tablas Huffman
    % customizadas
    %
    % Entradas:
    %   fname: Nombre del archivo comprimido *.huc
    %
    % Salidas:
    %   MSE : Error cuadrático medio entre la imagen original y la descomprimida
    %   RC  : Relación de compresión

    disptext = 1;  % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion jdes_custom:');
    end

    % Instante inicial
    tc = cputime;

    % Abrir el archivo comprimido .huc
    fid = fopen(fname, 'r');
    if fid == -1
        error('No se pudo abrir el archivo comprimido');
    end
    
    % Leer las dimensiones de la imagen original y ampliada
    m = double(fread(fid, 1, 'uint32'));  % Leer m (dimensión original)
    n = double(fread(fid, 1, 'uint32'));  % Leer n (dimensión original)
    mamp = double(fread(fid, 1, 'uint32')); % Leer mamp (dimensión ampliada)
    namp = double(fread(fid, 1, 'uint32')); % Leer namp (dimensión ampliada)

    % Leer el valor de caliQ (el factor de calidad)
    caliQ = double(fread(fid, 1, 'uint32'));  % Leer caliQ

    % Leer los componentes CodedY, CodedCb, CodedCr
    lenCodedY = double(fread(fid, 1, 'uint32'));
    ultY = double(fread(fid, 1, 'uint8'));
    CodedY = double(fread(fid, lenCodedY, 'uint8'));
    
    lenCodedCb = double(fread(fid, 1, 'uint32'));
    ultCb = double(fread(fid, 1, 'uint8'));
    CodedCb = double(fread(fid, lenCodedCb, 'uint8'));
    
    lenCodedCr = double(fread(fid, 1, 'uint32'));
    ultCr = double(fread(fid, 1, 'uint8'));
    CodedCr = double(fread(fid, lenCodedCr, 'uint8'));
    
    % Leer las tablas de Huffman
    ulenBITS1 = double(fread(fid, 1, 'uint8'));
    BITS_Y_DC = fread(fid, ulenBITS1, 'uint8');
    ulenHUFFVAL1 = double(fread(fid, 1, 'uint8'));
    HUFFVAL_Y_DC = fread(fid, ulenHUFFVAL1, 'uint8');
    
    ulenBITS2 = double(fread(fid, 1, 'uint8'));
    BITS_Y_AC = fread(fid, ulenBITS2, 'uint8');
    ulenHUFFVAL2 = double(fread(fid, 1, 'uint8'));
    HUFFVAL_Y_AC = fread(fid, ulenHUFFVAL2, 'uint8');
    
    ulenBITS3 = double(fread(fid, 1, 'uint8'));
    BITS_C_DC = fread(fid, ulenBITS3, 'uint8');
    ulenHUFFVAL3 = double(fread(fid, 1, 'uint8'));
    HUFFVAL_C_DC = fread(fid, ulenHUFFVAL3, 'uint8');
    
    ulenBITS4 = double(fread(fid, 1, 'uint8'));
    BITS_C_AC = fread(fid, ulenBITS4, 'uint8');
    ulenHUFFVAL4 = double(fread(fid, 1, 'uint8'));
    HUFFVAL_C_AC = fread(fid, ulenHUFFVAL4, 'uint8');
    
    fclose(fid);  % Cerrar el archivo

    % Decodificar los tres Scans a partir de los strings binarios
    scodrec1 = bytes2bits(CodedY, ultY);
    scodrec2 = bytes2bits(CodedCb, ultCb);
    scodrec3 = bytes2bits(CodedCr, ultCr);

    % Decodificación de Huffman personalizada para los tres componentes
    XScanrec = DecodeScans_custom(scodrec1, scodrec2, scodrec3, [mamp, namp], BITS_Y_DC, HUFFVAL_Y_DC, BITS_Y_AC, HUFFVAL_Y_AC, BITS_C_DC, HUFFVAL_C_DC, BITS_C_AC, HUFFVAL_C_AC);

    % Recuperar las matrices de etiquetas en orden natural a partir del zigzag
    Xlabrec = invscan(XScanrec);

    % Descuantización de etiquetas
    Xtransrec = desquantmat(Xlabrec, caliQ);

    % Aplicar la iDCT bidimensional
    Xamprec = imidct(Xtransrec, m, n);

    % Convertir de YCbCr a RGB
    Xrecrd = round(ycbcr2rgb(Xamprec / 255) * 255);
    Xrec = uint8(Xrecrd);

    % Restablecer el tamaño original
    Xrec = Xrec(1:m, 1:n, 1:3);

    % Generar nombre del archivo original
    [~, name, ~] = fileparts(fname);
    name = regexprep(name, '_caliQ\d+', '');
    nombreorig = strcat(name, '.bmp');
    
    % Leer la imagen original para el cálculo de MSE
    [X, ~, ~, ~, ~, ~, ~, TO] = imlee(nombreorig);

    % Obtener el tamaño del archivo comprimido
    fileInfo = dir(fname);
    TC = fileInfo.bytes;

    % Calcular la relación de compresión (RC)
    RC = 100 * (TO - TC) / TO;

    % Calcular el error cuadrático medio (MSE)
    MSE = sum(sum(sum((double(Xrec) - double(X)).^2))) / (m * n * 3);

    %{
    Test visual
    if disptext
        [m, n, p] = size(X);
        figure('Units', 'pixels', 'Position', [100 100 n m]);
        set(gca, 'Position', [0 0 1 1]);
        image(X);
        set(gcf, 'Name', 'Imagen original X');
        
        figure('Units', 'pixels', 'Position', [100 100 n m]);
        set(gca, 'Position', [0 0 1 1]);
        image(Xrec);
        set(gcf, 'Name', 'Imagen reconstruida Xrec');
    end
    %}
    
    % Genera nombre archivo descomprimido <nombre>_des_cus.bmp
    [~,name,~] = fileparts(fname);
    nombrecomp=strcat(name,'_des_cus.bmp');
    % Guarda imagen descomprimida
    imwrite(Xrec, nombrecomp);
    
    % Tiempo de ejecución
    e = cputime - tc;

    if disptext
        disp('Compresión y descompresión terminadas');
        disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
        disp('Terminado jdes_custom');
        disp('--------------------------------------------------');
        disp('--------------------------------------------------');
        disp(['Relación de compresión (RC): ', num2str(RC), '%']);
        disp(['Error cuadrático medio (MSE): ', num2str(MSE)]);
    end
end
