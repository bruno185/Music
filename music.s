* http://eightbitsoundandfury.ld8.org/programming.html
* Nodified : duration is now 2 bytes long (instead of 1 byte)
* Attention: the musical notes are shifted in the table of this article
* C is a G, D is a A, and so on
* For accurate tone, frequency must be decreased by 1
* because of 16 bits duration (it takes more time)

        put const.s     ; rom routines and vars

        DO 0
nonote  MAC             ; tune for a silence
* byte 1 : anything except 0
* byte 2 & 3 : duration 
* last byte : 00 (flag for no play)
        hex 01010000      
        EOM
        FIN

        org $8000

main    lda #<music
        ldx #>music
        jsr donote
end     rts

****** MUSIC tune
* 4 bytes for each note :
* frequency (1 byte), duration (2 bytes), flag (1 byte)
* flag : 01 ==> play ; 00 ==> no play (silence)
music   hex 60800001      ; C
        nonote
        hex 55800001      ; D
        nonote
        hex 4C000101      ; E     
        nonote
        hex 55000101      ; D
        nonote
        hex 60000101     ; C
        nonote
        hex 00

music2  hex 5F011001      ; C
        hex 00

****** MUSIC Routines
* plays a tune 
* input : address of tune stored in A/X (lo/hi)
donote  ldy #$00
        sta ptr         ; set pointer to tune
        stx ptr+1
playnot lda (ptr),y     ; get freqency
        beq enddn       ; flag for end of tune
        sta freq        
        iny
        lda (ptr),y     ; get duration lo
        sta dura
        iny
        lda (ptr),y     ; get duration hi
        sta dura+1
        iny        
        sty savy        ; save y
        lda (ptr),y     ; get flag
        beq np          ; = 0 : no play
        jsr play        ; <> 0 : play
        jmp nextnot
np      jsr noplay
nextnot ldy savy        ; restore y
        iny             ; prepare for next note
        jmp playnot      ; loop
enddn   rts
*
play    lda bell        ; clic
loop1   dey             ; y loop : duration 
        bne suite1
        lda dura        ; dec 16 bits duration value
        bne nodec
        dec dura+1
nodec   dec dura
        lda dura
        ora dura+1      ; test : dura = 0 ?
        beq endplay     ; yes : exit
suite1  dex             ; x loop : frequency
        bne loop1       ; clic when x = 0
        ldx freq        ; reload frequency
        jmp play        ; loop
endplay rts
*
noplay  lda dummy       ; same routin but no bell
loop2   dey
        bne suite1
        lda dura
        bne nodec
        dec dura+1
nodec2  dec dura
        beq endplay
suite2  dex
        bne loop1
        ldx freq
        jmp play
endnopl rts
freq    hex 00          ; frequency
dura    hex 0000        ; duration      
dummy   hex 00          
savy    hex 00          ; to save x register




