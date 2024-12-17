function XScanrec = DecodeScans_custom(CodedY, CodedCb, CodedCr, tam, BITS_Y_DC, HUFFVAL_Y_DC, BITS_Y_AC, HUFFVAL_Y_AC, BITS_C_DC, HUFFVAL_C_DC, BITS_C_AC, HUFFVAL_C_AC)

    disptext=1; % Flag de verbosidad
    if disptext
        disp('--------------------------------------------------');
        disp('Funcion DecodeScans_custom:');
    end

    % Instante inicial
    tc=cputime;

    [~, HUFFCODE_Y_DC] = HCodeTables(BITS_Y_DC, HUFFVAL_Y_DC);
    [~, HUFFCODE_Y_AC] = HCodeTables(BITS_Y_AC, HUFFVAL_Y_AC);
    [~, HUFFCODE_C_DC] = HCodeTables(BITS_C_DC, HUFFVAL_C_DC);
    [~, HUFFCODE_C_AC] = HCodeTables(BITS_C_AC, HUFFVAL_C_AC);

    [MINCODE_Y_DC,MAXCODE_Y_DC,VALPTR_Y_DC] = HDecodingTables(BITS_Y_DC, HUFFCODE_Y_DC);
    [MINCODE_Y_AC,MAXCODE_Y_AC,VALPTR_Y_AC] = HDecodingTables(BITS_Y_AC, HUFFCODE_Y_AC);
    [MINCODE_C_DC,MAXCODE_C_DC,VALPTR_C_DC] = HDecodingTables(BITS_C_DC, HUFFCODE_C_DC);
    [MINCODE_C_AC,MAXCODE_C_AC,VALPTR_C_AC] = HDecodingTables(BITS_C_AC, HUFFCODE_C_AC);

    YScanrec=DecodeSingleScan(CodedY,MINCODE_Y_DC,MAXCODE_Y_DC,VALPTR_Y_DC,HUFFVAL_Y_DC,MINCODE_Y_AC,MAXCODE_Y_AC,VALPTR_Y_AC,HUFFVAL_Y_AC,tam);
    CbScanrec=DecodeSingleScan(CodedCb,MINCODE_C_DC,MAXCODE_C_DC,VALPTR_C_DC,HUFFVAL_C_DC,MINCODE_C_AC,MAXCODE_C_AC,VALPTR_C_AC,HUFFVAL_C_AC,tam);
    CrScanrec=DecodeSingleScan(CodedCr,MINCODE_C_DC,MAXCODE_C_DC,VALPTR_C_DC,HUFFVAL_C_DC,MINCODE_C_AC,MAXCODE_C_AC,VALPTR_C_AC,HUFFVAL_C_AC,tam);

    % Reconstruye matriz 3-D
    XScanrec=cat(3,YScanrec,CbScanrec,CrScanrec);

    % Tiempo de ejecucion
    e=cputime-tc;

    if disptext
        disp('Scans decodificados');
        disp(sprintf('%s %1.6f', 'Tiempo de CPU:', e));
        disp('Terminado DecodeScans_custom');
    end

end