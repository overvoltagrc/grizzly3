
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

	BTFSS      GPIF_bit+0, BitPos(GPIF_bit+0)
	GOTO       L_interrupt0
	BTFSS      GP3_bit+0, BitPos(GP3_bit+0)
	GOTO       L_interrupt3
	MOVF       _PPM_level+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
L__interrupt77:
	CLRF       TMR0+0
	MOVLW      1
	MOVWF      _PPM_level+0
	GOTO       L_interrupt4
L_interrupt3:
	BTFSC      GP3_bit+0, BitPos(GP3_bit+0)
	GOTO       L_interrupt7
	MOVF       _PPM_level+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt76:
	MOVF       TMR0+0, 0
	MOVWF      _PPM_pulse+0
	CLRF       _PPM_level+0
L_interrupt7:
L_interrupt4:
	BCF        GPIF_bit+0, BitPos(GPIF_bit+0)
L_interrupt0:
	BTFSS      T1IF_bit+0, BitPos(T1IF_bit+0)
	GOTO       L_interrupt8
	MOVLW      255
	MOVWF      TMR1H+0
	INCF       _PWM_i+0, 1
	MOVF       _PWM_i+0, 0
	XORLW      20
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
	CLRF       _PWM_i+0
	MOVF       _PWM_value+0, 0
	SUBWF      _PWM_command+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt10
	DECF       _PWM_value+0, 1
	GOTO       L_interrupt11
L_interrupt10:
	MOVF       _PWM_command+0, 0
	SUBWF      _PWM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt12
	INCF       _PWM_value+0, 1
L_interrupt12:
L_interrupt11:
L_interrupt9:
	MOVF       _PWM_brake+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt13
	MOVLW      48
	MOVWF      GPIO+0
	GOTO       L_interrupt14
L_interrupt13:
	MOVF       _PWM_value+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt15
	MOVF       _PWM_direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt16
	MOVLW      33
	MOVWF      GPIO+0
	GOTO       L_interrupt17
L_interrupt16:
	MOVF       _PWM_direction+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt18
	MOVLW      18
	MOVWF      GPIO+0
L_interrupt18:
L_interrupt17:
	GOTO       L_interrupt19
L_interrupt15:
	CLRF       GPIO+0
L_interrupt19:
L_interrupt14:
	BCF        T1IF_bit+0, BitPos(T1IF_bit+0)
L_interrupt8:
L_end_interrupt:
L__interrupt82:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_syncPPM:

	CLRF       _i+0
L_syncPPM20:
	MOVLW      50
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM21
	CLRF       _PPM_pulse+0
L_syncPPM22:
	MOVF       _PPM_pulse+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_syncPPM23
	GOTO       L_syncPPM22
L_syncPPM23:
	MOVLW      56
	SUBWF      _PPM_pulse+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__syncPPM78
	MOVF       _PPM_pulse+0, 0
	SUBLW      131
	BTFSS      STATUS+0, 0
	GOTO       L__syncPPM78
	GOTO       L_syncPPM26
L__syncPPM78:
	CLRF       _i+0
	GOTO       L_syncPPM27
L_syncPPM26:
	INCF       _i+0, 1
L_syncPPM27:
	GOTO       L_syncPPM20
L_syncPPM21:
L_end_syncPPM:
	RETURN
; end of _syncPPM

_beep:

	CLRF       _j+0
	CLRF       _j+1
L_beep28:
	MOVF       FARG_beep_duration+1, 0
	SUBWF      _j+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__beep85
	MOVF       FARG_beep_duration+0, 0
	SUBWF      _j+0, 0
L__beep85:
	BTFSC      STATUS+0, 0
	GOTO       L_beep29
	BSF        GP1_bit+0, BitPos(GP1_bit+0)
	BSF        GP4_bit+0, BitPos(GP4_bit+0)
	MOVLW      166
	MOVWF      R13+0
L_beep31:
	DECFSZ     R13+0, 1
	GOTO       L_beep31
	NOP
	BCF        GP5_bit+0, BitPos(GP5_bit+0)
	BCF        GP4_bit+0, BitPos(GP4_bit+0)
	BCF        GP1_bit+0, BitPos(GP1_bit+0)
	BCF        GP0_bit+0, BitPos(GP0_bit+0)
	MOVLW      83
	MOVWF      R13+0
L_beep32:
	DECFSZ     R13+0, 1
	GOTO       L_beep32
	BSF        GP5_bit+0, BitPos(GP5_bit+0)
	BSF        GP0_bit+0, BitPos(GP0_bit+0)
	MOVLW      166
	MOVWF      R13+0
L_beep33:
	DECFSZ     R13+0, 1
	GOTO       L_beep33
	NOP
	BCF        GP5_bit+0, BitPos(GP5_bit+0)
	BCF        GP4_bit+0, BitPos(GP4_bit+0)
	BCF        GP1_bit+0, BitPos(GP1_bit+0)
	BCF        GP0_bit+0, BitPos(GP0_bit+0)
	MOVLW      83
	MOVWF      R13+0
L_beep34:
	DECFSZ     R13+0, 1
	GOTO       L_beep34
	INCF       _j+0, 1
	BTFSC      STATUS+0, 2
	INCF       _j+1, 1
	GOTO       L_beep28
L_beep29:
L_end_beep:
	RETURN
; end of _beep

_grizzly3_3POS:

L_grizzly3_3POS35:
	MOVLW      91
	SUBWF      _PPM_pulse+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__grizzly3_3POS79
	MOVF       _PPM_pulse+0, 0
	SUBLW      97
	BTFSS      STATUS+0, 0
	GOTO       L__grizzly3_3POS79
	GOTO       L_grizzly3_3POS36
L__grizzly3_3POS79:
	GOTO       L_grizzly3_3POS35
L_grizzly3_3POS36:
L_grizzly3_3POS39:
	MOVF       _PPM_pulse+0, 0
	SUBLW      56
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_3POS41
	MOVF       _PPM_pulse+0, 0
	MOVWF      _PPM_value+0
	MOVF       _PPM_pulse+0, 0
	SUBLW      125
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_3POS42
	MOVLW      125
	MOVWF      _PPM_value+0
L_grizzly3_3POS42:
	MOVLW      63
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_3POS43
	MOVLW      63
	MOVWF      _PPM_value+0
L_grizzly3_3POS43:
	MOVF       _PPM_value+0, 0
	SUBLW      97
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_3POS44
	MOVF       _PWM_direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_3POS45
	MOVLW      94
	SUBWF      _PPM_value+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	BTFSS      STATUS+0, 0
	DECF       R3+1, 1
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVLW      _PPM_map+0
	ADDWF      R0+0, 1
	MOVLW      hi_addr(_PPM_map+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      _PWM_command+0
	GOTO       L_grizzly3_3POS46
L_grizzly3_3POS45:
	CLRF       _PWM_command+0
	MOVF       _PWM_value+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_3POS47
	CLRF       _PWM_brake+0
	CLRF       _PWM_direction+0
L_grizzly3_3POS47:
L_grizzly3_3POS46:
	GOTO       L_grizzly3_3POS48
L_grizzly3_3POS44:
	MOVLW      91
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_3POS49
	MOVF       _PWM_direction+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_3POS50
	MOVF       _PPM_value+0, 0
	SUBLW      94
	MOVWF      R3+0
	CLRF       R3+1
	BTFSS      STATUS+0, 0
	DECF       R3+1, 1
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	MOVLW      _PPM_map+0
	ADDWF      R0+0, 1
	MOVLW      hi_addr(_PPM_map+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      _PWM_command+0
	GOTO       L_grizzly3_3POS51
L_grizzly3_3POS50:
	CLRF       _PWM_command+0
	MOVF       _PWM_value+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_3POS52
	CLRF       _PWM_brake+0
	MOVLW      1
	MOVWF      _PWM_direction+0
L_grizzly3_3POS52:
L_grizzly3_3POS51:
	GOTO       L_grizzly3_3POS53
L_grizzly3_3POS49:
	MOVF       _PWM_value+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_grizzly3_3POS54
	CLRF       _PWM_command+0
	GOTO       L_grizzly3_3POS55
L_grizzly3_3POS54:
	MOVLW      1
	MOVWF      _PWM_brake+0
L_grizzly3_3POS55:
	MOVLW      2
	MOVWF      _PWM_direction+0
L_grizzly3_3POS53:
L_grizzly3_3POS48:
	CLRF       _PPM_pulse+0
L_grizzly3_3POS41:
	GOTO       L_grizzly3_3POS39
L_end_grizzly3_3POS:
	RETURN
; end of _grizzly3_3POS

_grizzly3_2POS:

L_grizzly3_2POS56:
	MOVF       _PPM_pulse+0, 0
	SUBLW      69
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_2POS57
	GOTO       L_grizzly3_2POS56
L_grizzly3_2POS57:
L_grizzly3_2POS58:
	MOVF       _PPM_pulse+0, 0
	SUBLW      56
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_2POS60
	MOVF       _PPM_pulse+0, 0
	MOVWF      _PPM_value+0
	MOVF       _PPM_pulse+0, 0
	SUBLW      125
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_2POS61
	MOVLW      125
	MOVWF      _PPM_value+0
L_grizzly3_2POS61:
	MOVLW      63
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_2POS62
	MOVLW      63
	MOVWF      _PPM_value+0
L_grizzly3_2POS62:
	MOVF       _PPM_value+0, 0
	SUBLW      69
	BTFSC      STATUS+0, 0
	GOTO       L_grizzly3_2POS63
	MOVF       _PWM_direction+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__grizzly3_2POS80
	MOVF       _PWM_direction+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L__grizzly3_2POS80
	GOTO       L_grizzly3_2POS66
L__grizzly3_2POS80:
	MOVLW      63
	SUBWF      _PPM_value+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVLW      2
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_S+0
	MOVF       R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	MOVWF      R2+1
	RLF        R2+0, 1
	RLF        R2+1, 1
	BCF        R2+0, 0
	MOVF       R2+0, 0
	ADDLW      _PPM_map+0
	MOVWF      R0+0
	MOVLW      hi_addr(_PPM_map+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R2+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      _PWM_command+0
	GOTO       L_grizzly3_2POS67
L_grizzly3_2POS66:
	CLRF       _PWM_command+0
	MOVF       _PWM_value+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_2POS68
	CLRF       _PWM_brake+0
	MOVF       _PWM_last_direction+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_grizzly3_2POS69
	CLRF       _PWM_direction+0
	GOTO       L_grizzly3_2POS70
L_grizzly3_2POS69:
	MOVLW      1
	MOVWF      _PWM_direction+0
L_grizzly3_2POS70:
	MOVF       _PWM_direction+0, 0
	MOVWF      _PWM_last_direction+0
L_grizzly3_2POS68:
L_grizzly3_2POS67:
	GOTO       L_grizzly3_2POS71
L_grizzly3_2POS63:
	MOVF       _PWM_value+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_grizzly3_2POS72
	CLRF       _PWM_command+0
	GOTO       L_grizzly3_2POS73
L_grizzly3_2POS72:
	MOVLW      1
	MOVWF      _PWM_brake+0
L_grizzly3_2POS73:
	MOVLW      2
	MOVWF      _PWM_direction+0
L_grizzly3_2POS71:
	CLRF       _PPM_pulse+0
L_grizzly3_2POS60:
	GOTO       L_grizzly3_2POS58
L_end_grizzly3_2POS:
	RETURN
; end of _grizzly3_2POS

_main:

	BSF        STATUS+0, 5
	CALL       1023
	MOVWF      OSCCAL+0
	BCF        STATUS+0, 5
	MOVLW      3
	MOVWF      OPTION_REG+0
	MOVLW      4
	MOVWF      WPU+0
	CLRF       GPIO+0
	MOVLW      204
	MOVWF      TRISIO+0
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
	BSF        PEIE_bit+0, BitPos(PEIE_bit+0)
	BSF        GPIE_bit+0, BitPos(GPIE_bit+0)
	MOVLW      8
	MOVWF      IOC+0
	BCF        T1IF_bit+0, BitPos(T1IF_bit+0)
	BSF        T1IE_bit+0, BitPos(T1IE_bit+0)
	MOVLW      1
	MOVWF      T1CON+0
	CALL       _syncPPM+0
	MOVLW      1
	MOVWF      _PWM_brake+0
	BTFSS      GP2_bit+0, BitPos(GP2_bit+0)
	GOTO       L_main74
	CALL       _grizzly3_3POS+0
	GOTO       L_main75
L_main74:
	CALL       _grizzly3_2POS+0
L_main75:
L_end_main:
	GOTO       $+0
; end of _main
