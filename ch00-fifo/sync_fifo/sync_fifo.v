module sync_fifo(
    clk, 
    reset, 
    // write
    full, 
    write_en,
    write_data,
    // read
    emtpy,
    read_en, 
    read_data
)
// input and output
input               clk                 ;
input               reset               ;
// write
output              full                ; 
input               write_en            ;
input   [      7:0] write_data          ;
// read 
output              empty               ; 
input               read_en             ;
input   [      7:0] read_data           ;

// internals 
reg     [      7:0] mem[7:0]            ;

reg     [      3:0] write_ptr           ;
reg     [      3:0] write_ptr_nxt       ;
reg                 write_ptr_phase     ; 
reg                 write_ptr_phase_nxt ; 

reg     [      3:0] read_ptr            ;
reg     [      3:0] read_ptr_nxt        ;
reg                 read_ptr_phase      ; 
reg                 read_ptr_phase_nxt  ; 


// write ptr next 
always @(*) begin
   if (write_ptr == (8-1)) begin 
       write_ptr_nxt = 0;           // wrap-around 
       write_ptr_phase_nxt = ~write_ptr_phase;
   end else begin 
       write_ptr_nxt = write_ptr + 1;        
       write_ptr_phase_nxt = write_ptr_phase;
   end
end

// write ptr 
int i;
always @(posedge clk) begin
    if (reset) begin 
        for (i=0; i < 8; i++)
            mem[i] <= 0;
        write_ptr <= 0;
        write_ptr_phase <= 0;
    end else begin 
        if (!full && write_en) begin
            mem[write_ptr] <= write_data;        
            write_ptr <= write_ptr_nxt;
            write_ptr_phase <= write_ptr_phase_nxt;
        end
    end
end

// read ptr next 
always @(*) begin
   if (read_ptr == (8-1)) begin 
       read_ptr_nxt = 0;           // wrap-around 
       read_ptr_phase_nxt = ~read_ptr_phase;
   end else begin 
       read_ptr_nxt = read_ptr + 1;        
       read_ptr_phase_nxt = read_ptr_phase;
   end
end

// read ptr 
always @(posedge clk) begin
    if (reset) begin 
        read_ptr <= 0;
        read_ptr_phase <= 0;
    end else begin 
        if (!empty && reand_en) begin
           read_ptr <= read_ptr_nxt;
           read_ptr_phase <= read_ptr_phase_nxt;
        end
    end
end

assign full = (write_ptr_phase != read_ptr_phase) &&                 
              (write_ptr == read_ptr);

assign empty = (write_ptr_phase == read_ptr_phase) &&                 
               (write_ptr == read_ptr);

assign read_data = mem[read_ptr]; 

endmodule