initial begin
    initialize;

    // ===============================
    // PHASE 1: FILE VECTORS
    // ===============================
    eof = 0;

    while (eof == 0) begin
        @(negedge TICK);
        scan_file;

        if (eof == 0) begin
            @(posedge TICK);
            coverage_update;
            errors_check;
            display_line;

            prev_SR = {S,R};
            prev_Q  = Q_beh;
            VECTORCOUNT = VECTORCOUNT + 1;
        end
    end

    // ===============================
    // PHASE 2: RANDOM VECTORS
    // ===============================
    for (i = 0; i < 10; i = i + 1) begin
        gap = $urandom_range(1,5);

        // ✅ 你要的：随机 gap + posedge
        repeat (gap) @(posedge TICK);

        random_in;

        @(posedge TICK);
        coverage_update;
        errors_check;
        display_line;

        prev_SR = {S,R};
        prev_Q  = Q_beh;
        VECTORCOUNT = VECTORCOUNT + 1;
    end

    close_tb;
end
