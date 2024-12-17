function [CodedY, CodedCb, CodedCr, BITS_Y_DC, HUFFVAL_Y_DC, BITS_Y_AC, HUFFVAL_Y_AC, BITS_C_DC, HUFFVAL_C_DC, BITS_C_AC, HUFFVAL_C_AC] = EncodeScans_custom(XScan)
    % EncodeScans_custom: Codifica en binario los tres scans (Y, Cb, Cr) utilizando Huffman personalizado
    % según las frecuencias de aparición de los coeficientes DC y AC para cada scan.
    %
    % Entradas:
    %   XScan: Matriz de scans Y, Cb, Cr. Tamaño: mamp x namp x 3
    %           donde XScan(:,:,1) es Y, XScan(:,:,2) es Cb y XScan(:,:,3) es Cr.
    %
    % Salidas:
    %   CodedY, CodedCb, CodedCr: Cadenas binarias con los scans Y, Cb, y Cr codificados
    %   BITS_Y_DC, HUFFVAL_Y_DC: Tablas Huffman personalizadas para Y_DC
    %   BITS_Y_AC, HUFFVAL_Y_AC: Tablas Huffman personalizadas para Y_AC
    %   BITS_C_DC, HUFFVAL_C_DC: Tablas Huffman personalizadas para Cb_DC y Cr_DC
    %   BITS_C_AC, HUFFVAL_C_AC: Tablas Huffman personalizadas para Cb_AC y Cr_AC

    disptext=1; % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion EncodeScans_custom:');
    end

    % Instante inicial
    tc=cputime;
    
    % Extraemos los scans de luminancia y crominancia
    YScan = XScan(:,:,1);  % Luminancia Y
    CbScan = XScan(:,:,2); % Crominancia Cb
    CrScan = XScan(:,:,3); % Crominancia Cr

    % Recolectar coeficientes DC y AC para cada scan (Y, Cb, Cr)
    [Y_DC_Coefs, Y_AC_Coefs] = CollectScan(YScan);
    [Cb_DC_Coefs, Cb_AC_Coefs] = CollectScan(CbScan);
    [Cr_DC_Coefs, Cr_AC_Coefs] = CollectScan(CrScan);

    % Obtener las frecuencias de aparición de los coeficientes DC y AC para Y, Cb, y Cr
    FREQ_Y_DC = Freq256(Y_DC_Coefs); % Frecuencias de coeficientes DC de Y
    FREQ_Y_AC = Freq256(Y_AC_Coefs); % Frecuencias de coeficientes AC de Y
    
    FREQ_Cb_DC = Freq256(Cb_DC_Coefs); % Frecuencias de coeficientes DC de Cb
    FREQ_Cb_AC = Freq256(Cb_AC_Coefs); % Frecuencias de coeficientes AC de Cb

    FREQ_Cr_DC = Freq256(Cr_DC_Coefs); % Frecuencias de coeficientes DC de Cr
    FREQ_Cr_AC = Freq256(Cr_AC_Coefs); % Frecuencias de coeficientes AC de Cr
    
    %Se suman las frecuencias de Cb y Cr
    FREQ_C_DC = FREQ_Cb_DC + FREQ_Cr_DC;
    FREQ_C_AC = FREQ_Cb_AC + FREQ_Cr_AC;
    
    % Construcción de las tablas Huffman personalizadas para Y (luminancia)
    [BITS_Y_DC, HUFFVAL_Y_DC] = HSpecTables(FREQ_Y_DC); % Tabla Huffman para Y_DC
    [BITS_Y_AC, HUFFVAL_Y_AC] = HSpecTables(FREQ_Y_AC); % Tabla Huffman para Y_AC

    % Construcción de las tablas Huffman personalizadas para Cb y Cr (crominancia)
    [BITS_C_DC, HUFFVAL_C_DC] = HSpecTables(FREQ_C_DC); % Tabla Huffman para Cb_DC y Cr_DC
    [BITS_C_AC, HUFFVAL_C_AC] = HSpecTables(FREQ_C_AC); % Tabla Huffman para Cb_AC y Cr_AC
    
    [HUFFSIZE_Y_DC, HUFFCODE_Y_DC] = HCodeTables(BITS_Y_DC, HUFFVAL_Y_DC);
    [EHUFCO_Y_DC, EHUFSI_Y_DC] = HCodingTables(HUFFSIZE_Y_DC, HUFFCODE_Y_DC, HUFFVAL_Y_DC);
    ehuf_Y_DC=[EHUFCO_Y_DC EHUFSI_Y_DC];
    
    [HUFFSIZE_Y_AC, HUFFCODE_Y_AC] = HCodeTables(BITS_Y_AC, HUFFVAL_Y_AC);
    % Construye Tablas de Codificacion Huffman
    [EHUFCO_Y_AC, EHUFSI_Y_AC] = HCodingTables(HUFFSIZE_Y_AC, HUFFCODE_Y_AC, HUFFVAL_Y_AC);
    ehuf_Y_AC=[EHUFCO_Y_AC EHUFSI_Y_AC];
    
    [HUFFSIZE_C_DC, HUFFCODE_C_DC] = HCodeTables(BITS_C_DC, HUFFVAL_C_DC);
    % Construye Tablas de Codificacion Huffman
    [EHUFCO_C_DC, EHUFSI_C_DC] = HCodingTables(HUFFSIZE_C_DC, HUFFCODE_C_DC, HUFFVAL_C_DC);
    ehuf_C_DC=[EHUFCO_C_DC EHUFSI_C_DC];
    
    [HUFFSIZE_C_AC, HUFFCODE_C_AC] = HCodeTables(BITS_C_AC, HUFFVAL_C_AC);
    % Construye Tablas de Codificacion Huffman
    [EHUFCO_C_AC, EHUFSI_C_AC] = HCodingTables(HUFFSIZE_C_AC, HUFFCODE_C_AC, HUFFVAL_C_AC);
    ehuf_C_AC=[EHUFCO_C_AC EHUFSI_C_AC];
    
    % Codificar los coeficientes DC y AC para cada scan (Y, Cb, Cr)
    CodedY = EncodeSingleScan(YScan, Y_DC_Coefs, Y_AC_Coefs, ehuf_Y_DC, ehuf_Y_AC);
    CodedCb = EncodeSingleScan(CbScan, Cb_DC_Coefs, Cb_AC_Coefs, ehuf_C_DC, ehuf_C_AC);
    CodedCr = EncodeSingleScan(CrScan, Cr_DC_Coefs, Cr_AC_Coefs, ehuf_C_DC, ehuf_C_AC);

    % Tiempo de ejecucion
    e=cputime-tc;

    if disptext
        disp('Scans codificados');
        disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
        disp('Terminado EncodeScans_custom');
    end
end

