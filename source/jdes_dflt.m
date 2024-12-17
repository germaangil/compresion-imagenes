function [MSE,RC]=jdes_dflt(fname)

    % jdes_dflt: Descompresión de imágenes comprimidas con tablas Huffman por defecto
    %
    % Entradas:
    %   fname: Nombre del archivo comprimido *.hud
    %
    % Salidas:
    %   MSE : Error cuadrático medio entre la imagen original y la descomprimida
    %   RC  : Relación de compresión

    disptext = 1;  % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion jdes_dflt:');
    end

    % Instante inicial
    tc = cputime;

    % Abrir el archivo comprimido .hud
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
    CodedY = double(fread(fid,lenCodedY, 'uint8'));
    
    lenCodedCb = double(fread(fid, 1, 'uint32'));
    ultCb = double(fread(fid, 1, 'uint8'));
    CodedCb = double(fread(fid, lenCodedCb, 'uint8'));
    
    lenCodedCr = double(fread(fid, 1, 'uint32'));
    ultCr = double(fread(fid, 1, 'uint8'));
    CodedCr = double(fread(fid, lenCodedCr, 'uint8'));
    
    fclose(fid);  % Cerrar el archivo

    scodrec1=bytes2bits(CodedY, ultY);
    scodrec2=bytes2bits(CodedCb, ultCb);
    scodrec3=bytes2bits(CodedCr, ultCr);
    
    % Decodifica los tres Scans a partir de strings binarios
    XScanrec=DecodeScans_dflt(scodrec1,scodrec2,scodrec3,[mamp namp]);

    % Recupera matrices de etiquetas en orden natural
    %  a partir de orden zigzag
    Xlabrec=invscan(XScanrec);

    % Descuantizacion de etiquetas
    Xtransrec=desquantmat(Xlabrec, caliQ);

    % Calcula iDCT bidimensional en bloques de 8 x 8 pixeles
    % Como resultado, reconstruye una imagen YCbCr con tamaño ampliado
    Xamprec = imidct(Xtransrec,m, n);

    % Convierte a espacio de color RGB
    % Para ycbcr2rgb: % Intervalo [0,255]->[0,1]->[0,255]
    Xrecrd=round(ycbcr2rgb(Xamprec/255)*255);
    Xrec=uint8(Xrecrd);

    % Repone el tamaño original
    Xrec=Xrec(1:m,1:n, 1:3);
    
    % Genera nombre archivo original <name>.bmp
    [~,name,~] = fileparts(fname);
    name = regexprep(name, '_caliQ\d+', '');
    nombreorig=strcat(name,'.bmp');
    
    [X, ~, ~, ~, ~, ~, ~, TO]=imlee(nombreorig);
    
    fileInfo = dir(fname);  % Obtiene la información del archivo comprimido
    TC = fileInfo.bytes;    % Tamaño del archivo comprimido en bytes
    
    % Calcular la relación de compresión (RC)
    RC = 100 * (TO - TC) / TO;
    
    % Calcular el error cuadratico medio (MSE)
    MSE=(sum(sum(sum((double(Xrec)-double(X)).^2))))/(m*n*3);
    
    %{
    Test visual
    if disptext
        [m,n,p] = size(X);
        figure('Units','pixels','Position',[100 100 n m]);
        set(gca,'Position',[0 0 1 1]);
        image(X); 
        set(gcf,'Name','Imagen original X');
        figure('Units','pixels','Position',[100 100 n m]);
        set(gca,'Position',[0 0 1 1]);
        image(Xrec);
        set(gcf,'Name','Imagen reconstruida Xrec');
    end
    %}
    
    % Genera nombre archivo descomprimido <nombre>_des_def.bmp
    [~,name,~] = fileparts(fname);
    nombrecomp=strcat(name,'_des_def.bmp');
    % Guarda imagen descomprimida
    imwrite(Xrec, nombrecomp);

    % Tiempo de ejecucion
    e=cputime-tc;

    if disptext
        disp('Compresion y descompresion terminadas');
        disp(sprintf('%s %1.6f', 'Tiempo total de CPU:', e));
        disp('Terminado jdes_dflt');
        disp('--------------------------------------------------');
        disp('--------------------------------------------------');
        disp(['Relación de compresión (RC): ', num2str(RC), '%']);
        disp(['Error cuadratico medio (MSE): ', num2str(MSE)]);
    end
end