module CPU(CK, RST, IA, ID, DA, DD, RW);
    input CK, RST;
    input [15:0] ID;
    output RW;
    output [15:0] IA, DA;
    inout [15:0] DD;

    reg [1:0] STAGE;

    // program counter
    reg [15:0] PC, PCI, PCC;
    reg FLAG;

    assign IA = PC;

    // decoder
    reg [15:0] INST;
    wire [3:0] OPCODE, OPR1, OPR2, OPR3;
    wire [7:0] IMM;

    assign OPCODE = INST[15:12];
    assign OPR1 = INST[11:8];
    assign OPR2 = INST[7:4];
    assign OPR3 = INST[3:0];
    assign IMM = INST[7:0];

    // registers
    reg [15:0] RF [15:0];

    // for debug
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;
    assign R0 = RF[0];
    assign R1 = RF[1];
    assign R2 = RF[2];
    assign R3 = RF[3];
    assign R4 = RF[4];
    assign R5 = RF[5];
    assign R6 = RF[6];
    assign R7 = RF[7];
    assign R8 = RF[8];
    assign R9 = RF[9];
    assign R10 = RF[10];
    assign R11 = RF[11];
    assign R12 = RF[12];
    assign R13 = RF[13];
    assign R14 = RF[14];
    assign R15 = RF[15];

    // ALU
    reg [15:0] FUA, FUB, FUC;

    // load & store
    reg [15:0] LSUA, LSUB, LSUC;
    reg RW;

    assign DA = LSUB;
    assign DD = ((RW == 0) ? LSUA : 'b z);

    // bus
    wire [15:0] ABUS, BBUS, CBUS;

    assign ABUS = (OPR2 == 0 ? 0 : RF[OPR2]);
    assign BBUS = (OPR3 == 0 ? 0 : RF[OPR3]);
    assign CBUS = (OPCODE[3] == 0 ? FUC : (
        OPCODE[3:1] == 'b 101 ? LSUC : (
            OPCODE == 'b 1100 ? {8'b 0, IMM} : (
                OPCODE == 'b 1000 ? PCC : 'b z
            )
        )
    ));

    always @(posedge CK) begin
        if (RST == 1) begin
            PC <= 0;
            STAGE <= 0;
            // read mode
            RW <= 1;

        end else begin
            if (STAGE == 0) begin
                INST <= ID;

                STAGE <= 1;
            end else if (STAGE == 1) begin
                if (OPCODE[3] == 0) begin
                    // OPCODE == 0xxx
                    FUA <= ABUS;
                    FUB <= BBUS;
                end else if (OPCODE[2] == 0) begin
                    if (OPCODE[1] == 1) begin
                        // OPCODE == 101x
                        // memory load & store
                        LSUA <= ABUS;
                        LSUB <= BBUS;
                    end
                end else if (OPCODE[1:0] == 'b 00) begin
                    // OPCODE == 1100
                    // set lower bit
                end else begin
                    // undefined instruction
                end

                // change program counter
                if ((OPCODE[3:0] == 'b 1000) || OPCODE[3:0] == 'b 1001 && FLAG == 1)
                    PCI <= BBUS;
                else
                    PCI <= PC + 1;

                STAGE <= 2;
            end else if (STAGE == 2) begin
                if (OPCODE[3] == 0) begin
                    // OPCODE == 0xxx
                    case (OPCODE[2:0])
                    'b 0000: FUC <= FUA + FUB;
                    'b 0001: FUC <= FUA - FUB;
                    'b 0010: FUC <= FUA >> FUB;
                    'b 0011: FUC <= FUA << FUB;
                    'b 0100: FUC <= FUA | FUB;
                    'b 0101: FUC <= FUA & FUB;
                    'b 0110: FUC <= ~FUA;
                    'b 0111: FUC <= FUA ^ FUB;
                    endcase
                end else if (OPCODE[2:1] == 'b 01) begin
                    // OPCODE == 101x
                    // memory load & store
                    if (OPCODE[0] == 1) begin
                        // load data
                        RW <= 1;
                        LSUC <= DD;
                    end else begin
                        // store data
                        RW <= 0;
                    end
                end

                if (OPCODE == 'b 1000) begin
                    PCC <= PC + 1;
                end

                STAGE <=3;
            end else if (STAGE == 3) begin
                RF[OPR1] <= CBUS;
                PC <= PCI;
                // update flag
                if (FUC == 0) FLAG <= 1;
                else FLAG <= 0;

                STAGE <= 0;
            end
        end
    end

endmodule