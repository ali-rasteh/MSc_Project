*MSc Project : SRAM 6T simulation
*	changes from cadence version:
*
*	abreviations :
*	LCA : leakage calibration activation
*	LCR : leakage calibration reset
*	LCP : leakage calibration phase
*	LCF : leakage calibration flag
*	GR 	: Global Reset

************************************	library configurations	*********************************************
*For optimal accuracy, convergence, and runtime
***************************************************
*.option list node
.options POST
*.options INGOLD=2     DCON=1
*.options GSHUNT=1e-12 RMIN=1e-15 
*.options ABSTOL=1e-5  ABSVDC=1e-4 
*.options RELTOL=1e-2  RELVDC=1e-2 
*.options NUMDGT=4     PIVOT=13
.option runlvl=1
.option	FAST
.option	AUTOSTOP				* reduce simulation time by stopping your simulation as soon as the last measurement is completed by specifying the following option
.option notop noelchk			* reduce simulation time by bypassing element checking and suppressing topology checking with the following options
.option altcc altchk			* if using .ALTER statement, reduce netlist processing and checking time with the following options
.option sim_la					*  for post-layout  netlists, use RC reductions techniques
***************************************************

.prot

*.lib 'crn90g_2d5_lk_v1d2p1.l' TT

.lib 'crn40lp_2d5_v1d3.l' stat
.lib 'crn40lp_2d5_v1d3.l' Total
.lib 'crn40lp_2d5_v1d3.l' tt
.lib 'crn40lp_2d5_v1d3.l' TTG
*.lib 'crn40lp_2d5_v1d3.l' global

.unprot


*************************************	parameters definition	********************************************
.param VDD = 0.4
.param VDD_enhanced = 0.65			* for VDD = 0.4
*.param VDD_enhanced = 0.69			* for VDD = 0.45
.param VDD_nominal = 1.1
.param Write_value = 0.0

.param T_clk=500n
.param T_simulation=15*T_clk
.param step_simulation=T_clk/500
.param T_sampling=0.9*T_simulation
.param MC_num=20
.param total_flag=0
.param total_flag_NV=1				* total_flag nonvariation
.param global_flag=1
.param mismatch_flag=1

.param nt=1024
.param nint=128
.param nref=9
.param n_compensation_max=1500
.param n_sink=n_compensation_max/(nref-1)

.param N0=200
.param nr=768


*.param I_leak_1cell_27		=21p			* VDD = 1.1V
*.param I_leak_1cell_120	=875p			* VDD = 1.1V
*.param I_leak_1cell_120	=761p			* VDD = 1.0V
*.param I_leak_1cell_120	=659p			* VDD = 0.9V
*.param I_leak_1cell_120	=568p			* VDD = 0.8V
*.param I_leak_1cell_120	=486p			* VDD = 0.7V
*.param I_leak_1cell_120	=414p			* VDD = 0.6V
*.param I_leak_1cell_120	=380p			* VDD = 0.55V
*.param I_leak_1cell_120	=349p			* VDD = 0.5V
*.param I_leak_1cell_120	=319p			* VDD = 0.45V
.param I_leak_1cell_120	=291p			* VDD = 0.4V
*.param I_leak_1cell_120	=264p			* VDD = 0.35V
*.param I_leak_1cell_120	=238p			* VDD = 0.3V
*.param I_leak_1cell_120	=213p			* VDD = 0.25V
*.param I_leak_1cell_120	=187p			* VDD = 0.2V



.param I_leak_excess_write_120				='(2*nint-2)*I_leak_1cell_120'
.param I_BLB_leak_comp_120					='n_sink*I_leak_1cell_120'
.param I_dummy_leak_120						='nt*I_leak_1cell_120'
.param I_leak_precision_120					='0.5*n_sink*I_leak_1cell_120'
.param I_leak_BL_120						='N0*I_leak_1cell_120'
.param I_leak_BLB_120						='(nt-N0)*I_leak_1cell_120'

.param I_leak_excess_write_120_gauss		=agauss(I_leak_excess_write_120,	'0.49*0.05*nt*I_leak_1cell_120',	1)
.param I_BLB_leak_comp_120_gauss			=agauss(I_BLB_leak_comp_120, 		'0.42*0.05*nt*I_leak_1cell_120',	1)
.param I_dummy_leak_120_gauss				=agauss(I_dummy_leak_120, 			'1.00*0.05*nt*I_leak_1cell_120',	1)
.param I_leak_precision_120_gauss			=agauss(I_leak_precision_120, 		'0.30*0.05*nt*I_leak_1cell_120',	1)
.param I_leak_BL_120_gauss					=agauss(I_leak_BL_120, 				'0.31*0.05*nt*I_leak_1cell_120',	1)
.param I_leak_BLB_120_gauss					=agauss(I_leak_BLB_120, 			'0.95*0.05*nt*I_leak_1cell_120',	1)



.param Lmin=40n
.param Wmin=108n

.param C_BL=920f
.param C_WL=360f

*************************************	temperature configurations	********************************************
.temp 120


*************************************	subcircuits definition	********************************************
.subckt	SRAM_6T	VDD GROND WL	BL	BLB
x1	BL	WL	Q	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'	*PG left
x2	Q	QB	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*PU	left
x3	Q	QB	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*PD left
x4	QB	Q	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*PU right
x5	QB	Q	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*PD right
x6	BLB	WL	QB	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'	*PG rigth
.ends

*******************************************************************

.subckt	SRAM_6T_NV	VDD GROND WL	BL	BLB
x1	BL	WL	Q	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'	*PG left
x2	Q	QB	VDD	VDD	pch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*PU	left
x3	Q	QB	GROND	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*PD left
x4	QB	Q	VDD	VDD	pch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*PU right
x5	QB	Q	GROND	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*PD right
x6	BLB	WL	QB	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'	*PG rigth
.ends

*******************************************************************

*.subckt	sense_amp	VDD GROND X XB SE output
*x1-1	final_in_left	X	s1-1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x2-1	d2	XB	s1-1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x3-1	final_in_left	d2-1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x4-1	d2-1	d2-1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x5-1	s1-1	SE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

*x1-2	d1-2	X	s1-2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x2-2	final_in_right	XB	s1-2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x3-2	d1-2	d1-2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x4-2	final_in_right	d1-2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x5-2	s1-2	SE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

*x1-3	d1-3	final_in_left	s1-3	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x2-3	OUTPUTB	final_in_right	s1-3	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x3-3	d1-3	d1-3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x4-3	OUTPUTB	d1-3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x5-3	s1-3	SE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

*x1	OUTPUT	OUTPUTB	VDD VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*x2	OUTPUT	OUTPUTB	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.9*Wmin'	l='Lmin'

*x-reset	final_in_left	SE	final_in_right	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
*.ends

*******************************************************************

.subckt	sense_amp	VDD GROND IN+ IN- SE OUT	OUT#
x_CS	D_CS	SE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x_IN+	D_IN+	IN+	D_CS	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'
x_IN-	D_IN-	IN-	D_CS	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'

x_N_INVR	OUT1	OUT1#	D_IN-	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x_P_INVR	OUT1	OUT1#	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x_N_INVL	OUT1#	OUT1	D_IN+	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x_P_INVL	OUT1#	OUT1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

x_PCH_R	OUT1	SE	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x_PCH_L	OUT1#	SE	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

xNOT1 VDD GROND	OUT1	OUT#	NOT
xNOT2 VDD GROND	OUT1#	OUT	NOT
.ends

*******************************************************************

.subckt	sense_amp_2	VDD GROND VIN+ VIN- SE OUT	OUT#
xNOT1 VDD GROND	SE	SE#	NOT

x1	D_CS	SE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x2	O1-	VIN+	D_CS	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x3	O1+	VIN-	D_CS	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x4	O1-	SE		VDD		VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x5	O1+	SE		VDD		VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x6	OUT-	SE#		GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x7	OUT-	OUT+	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x8	OUT+	OUT-	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x9	OUT+	SE#		GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x10	OUT-	O1+		D_M12	VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x11	OUT+	O1-		D_M13	VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x12	D_M12	OUT+	VDD		VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'
x13	D_M13	OUT-	VDD		VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'

xNOT2 VDD GROND	OUT-	OUT		NOT
xNOT3 VDD GROND	OUT+	OUT#	NOT
.ends

*******************************************************************

.subckt	write_driver	VDD GROND BL	BLB	WE	DATA_IN
x1-1	DATA_INB	DATA_IN	VDD VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'
x2-1	DATA_INB	DATA_IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'

x1-2	DATA_INBB	DATA_INB	VDD VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'
x2-2	DATA_INBB	DATA_INB	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'

x-PG1	BLB	WE	DATA_INB GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'
x-PG2	BL	WE	DATA_INBB GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='40*Wmin'	l='Lmin'
.ends

*******************************************************************

.subckt TG VDD GROND IN	CTRL OUT
x1	IN	CTRL	OUT	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5*Wmin'	l='Lmin'	*NMOS
x2	OUT	CTRL#	IN	VDD		pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5*Wmin'	l='Lmin'	*PMOS
xNOT1 VDD GROND	CTRL	CTRL#	NOT
.ends

*******************************************************************

.subckt NOT VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_NV VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_large_size VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='30*Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='30*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_VM_high VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='50*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_VM_high_NV VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='50*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_VM_low VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='50*Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_VM_low_NV VDD GROND IN OUT
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='50*Wmin'	l='Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOT_delay VDD GROND IN OUT	l_NOT=20
x1	OUT	IN	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='l_NOT*Lmin'	*NMOS
x2	OUT	IN	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='l_NOT*Lmin'		*PMOS
.ends

*******************************************************************

.subckt NAND2 VDD GROND IN1 IN2 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN2	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.5*Wmin'	l='Lmin'	*down NMOS
x2	OUT	IN1	D1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.5*Wmin'	l='Lmin'		*upper NMOS
x3	OUT	IN2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x4	OUT	IN1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOR2 VDD GROND IN1 IN2 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'			*upper PMOS
x2	OUT	IN1	D1	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'			*down PMOS
x3	OUT	IN2	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x4	OUT	IN1	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
.ends

*******************************************************************

.subckt NAND3 VDD GROND IN1 IN2 IN3 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN3	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*down NMOS
x2	D2	IN2	D1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'	*Intermediate NMOS
x3	OUT	IN1	D2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'		*upper NMOS
x4	OUT	IN3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x5	OUT	IN2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x6	OUT	IN1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOR3 VDD GROND IN1 IN2 IN3 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.5*Wmin'	l='Lmin'			*upper PMOS
x2	D2	IN2	D1	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.5*Wmin'	l='Lmin'			*Intermediate PMOS
x3	OUT	IN1	D2	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.5*Wmin'	l='Lmin'			*down PMOS
x4	OUT	IN3	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x5	OUT	IN2	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x6	OUT	IN1	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
.ends

*******************************************************************

.subckt NAND4 VDD GROND IN1 IN2 IN3	IN4 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN4	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.2*Wmin'	l='Lmin'	*down NMOS
x2	D2	IN3	D1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.2*Wmin'	l='Lmin'	*Intermediate NMOS
x3	D3	IN2	D2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.2*Wmin'	l='Lmin'	*Intermediate NMOS
x4	OUT	IN1	D3	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='3.2*Wmin'	l='Lmin'		*upper NMOS
x5	OUT	IN4	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x6	OUT	IN3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x7	OUT	IN2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x8	OUT	IN1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOR4 VDD GROND IN1 IN2 IN3	IN4 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN4	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4.6*Wmin'	l='Lmin'			*upper PMOS
x2	D2	IN3	D1	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4.6*Wmin'	l='Lmin'			*Intermediate PMOS
x3	D3	IN2	D2	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4.6*Wmin'	l='Lmin'			*Intermediate PMOS
x4	OUT	IN1	D3	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4.6*Wmin'	l='Lmin'			*down PMOS
x5	OUT	IN4	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x6	OUT	IN3	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x7	OUT	IN2	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x8	OUT	IN1	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
.ends

*******************************************************************

.subckt NAND5 VDD GROND IN1 IN2 IN3	IN4	IN5 OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN5	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4*Wmin'	l='Lmin'	*down NMOS
x2	D2	IN4	D1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4*Wmin'	l='Lmin'	*Intermediate NMOS
x3	D3	IN3	D2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4*Wmin'	l='Lmin'	*Intermediate NMOS
x4	D4	IN2	D3	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4*Wmin'	l='Lmin'		*Intermediate NMOS
x5	OUT	IN1	D4	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='4*Wmin'	l='Lmin'		*upper NMOS
x6	OUT	IN5	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x7	OUT	IN4	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x8	OUT	IN3	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x9	OUT	IN2	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
x10	OUT	IN1	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='1.15*Wmin'	l='Lmin'		*PMOS
.ends

*******************************************************************

.subckt NOR5 VDD GROND IN1 IN2 IN3	IN4 IN5	OUT						* IN1 is the fastest signal and so on ...
x1	D1	IN5	VDD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5.75*Wmin'	l='Lmin'			*upper PMOS
x2	D2	IN4	D1	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5.75*Wmin'	l='Lmin'			*Intermediate PMOS
x3	D3	IN3	D2	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5.75*Wmin'	l='Lmin'			*Intermediate PMOS
x4	D4	IN2	D3	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5.75*Wmin'	l='Lmin'			*down PMOS
x5	OUT	IN1	D4	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='5.75*Wmin'	l='Lmin'			*down PMOS
x6	OUT	IN5	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x7	OUT	IN4	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x8	OUT	IN3	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x9	OUT	IN2	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
x10	OUT	IN1	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='Wmin'	l='Lmin'	*NMOS
.ends

*******************************************************************

.subckt XOR2 VDD GROND IN1 IN2 OUT
xNOT1	VDD	GROND	IN1	IN1#	NOT
xNOT2	VDD	GROND	IN2	IN2#	NOT
xNAND1	VDD	GROND	IN1 IN2#	OUT1	NAND2
xNAND2	VDD GROND	IN1#	IN2	OUT2	NAND2
xNAND3	VDD GROND	OUT1	OUT2	OUT	NAND2
.ends

*******************************************************************

.subckt RING_OSC VDD GROND ENABLE L3 L7 R5 R7	OUT

x1	GNDL1	L3	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2	GNDL2	L7	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x3	GNDR1	R7	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x4	GNDR2	R5	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x5	GND_ENABLE	ENABLE	GROND	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'

xNOT1 VDD GND_ENABLE	IN	IN_L	NOT

xNOT1_L1 VDD GNDL1	IN_L	OUT1_L1	NOT
xNOT2_L1 VDD GNDL1	OUT1_L1	OUT2_L1	NOT
xNOT3_L1 VDD GNDL1	OUT2_L1	IN_R	NOT

xNOT1_L2 VDD GNDL2	IN_L	OUT1_L2	NOT
xNOT2_L2 VDD GNDL2	OUT1_L2	OUT2_L2	NOT
xNOT3_L2 VDD GNDL2	OUT2_L2	OUT3_L2	NOT
xNOT4_L2 VDD GNDL2	OUT3_L2	OUT4_L2	NOT
xNOT5_L2 VDD GNDL2	OUT4_L2	OUT5_L2	NOT
xNOT6_L2 VDD GNDL2	OUT5_L2	OUT6_L2	NOT
xNOT7_L2 VDD GNDL2	OUT6_L2	IN_R	NOT

xNOT1_R1 VDD GNDR1	IN_R	OUT1_R1	NOT
xNOT2_R1 VDD GNDR1	OUT1_R1	OUT2_R1	NOT
xNOT3_R1 VDD GNDR1	OUT2_R1	OUT3_R1	NOT
xNOT4_R1 VDD GNDR1	OUT3_R1	OUT4_R1	NOT
xNOT5_R1 VDD GNDR1	OUT4_R1	OUT5_R1	NOT
xNOT6_R1 VDD GNDR1	OUT5_R1	OUT6_R1	NOT
xNOT7_R1 VDD GNDR1	OUT6_R1	IN	NOT

xNOT1_R2 VDD GNDR2	IN_R	OUT1_R2	NOT
xNOT2_R2 VDD GNDR2	OUT1_R2	OUT2_R2	NOT
xNOT3_R2 VDD GNDR2	OUT2_R2	OUT3_R2	NOT
xNOT4_R2 VDD GNDR2	OUT3_R2	OUT4_R2	NOT
xNOT5_R2 VDD GNDR2	OUT4_R2	IN	NOT

xNAND1	VDD	GND	IN	ENABLE	OUT_NOT	NAND2
xNOT2	VDD	GND	OUT_NOT	OUT	NOT

.ends

*******************************************************************

.subckt RE_DFF VDD GROND D	CLK	RESET	Q
xNOT1 VDD GROND	CLK	CLK#	NOT

xNOT2 VDD GROND	D	IN_TG_LD	NOT
x1_LD	IN_TG_LD	CLK#	OUT1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_LD	OUT1	CLK	IN_TG_LD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
xNOT3 VDD GROND	OUT1	IN2	NOT
xNOT4 VDD GROND	IN2	IN_TG_LU	NOT
x1_LU	IN_TG_LU	CLK	OUT1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_LU	OUT1	CLK#	IN_TG_LU	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'


xNOT5 VDD GROND	IN2	IN_TG_RD	NOT
x1_RD	IN_TG_RD	CLK	OUT2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_RD	OUT2	CLK#	IN_TG_RD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
xNOT6 VDD GROND	OUT2	OUT2#	NOT
xNOT7 VDD GROND	OUT2#	IN_TG_RU	NOT
xNOT8 VDD GROND	OUT2#	OUT3	NOT
xNOR1 VDD GROND	OUT3	RESET	Q	NOR2
*xNOT9 VDD GROND	Q	QB	NOT
x1_RU	IN_TG_RU	CLK#	OUT2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_RU	OUT2	CLK	IN_TG_RU	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'

.ends

*******************************************************************

.subckt FE_DFF VDD GROND D	CLK	RESET	Q	QB
xNOT1 VDD GROND	CLK	CLK#	NOT

xNOT2 VDD GROND	D	IN_TG_LD	NOT
x1_LD	IN_TG_LD	CLK	OUT1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_LD	OUT1	CLK#	IN_TG_LD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
xNOT3 VDD GROND	OUT1	IN2	NOT
xNOT4 VDD GROND	IN2	IN_TG_LU	NOT
x1_LU	IN_TG_LU	CLK#	OUT1	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_LU	OUT1	CLK	IN_TG_LU	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'


xNOT5 VDD GROND	IN2	IN_TG_RD	NOT
x1_RD	IN_TG_RD	CLK#	OUT2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_RD	OUT2	CLK	IN_TG_RD	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
xNOT6 VDD GROND	OUT2	OUT2#	NOT
xNOT7 VDD GROND	OUT2#	IN_TG_RU	NOT
xNOT8 VDD GROND	OUT2#	OUT3	NOT
xNOR1 VDD GROND	OUT3	RESET	Q	NOR2
xNOT9 VDD GROND	Q	QB	NOT
x1_RU	IN_TG_RU	CLK	OUT2	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_RU	OUT2	CLK#	IN_TG_RU	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'

.ends

*******************************************************************

.subckt FE_FER_DFF VDD GROND D	CLK	RESET	Q	QB		*falling edge CLK_falling edge reset_DFF
xFE_DFF1	VDD	GROND	D	CLK	GROND	Q1	QB1	FE_DFF
xFE_DFF2	VDD	GROND	Q1	RESET	GROND	Qreset	Qreset_B	FE_DFF
xFE_DFF3	VDD	GROND	Qreset	CLK	GROND	Qreset_pre Qreset_pre_B	FE_DFF
xNOR1	VDD GROND Qreset_pre_B Qreset_B NOR_out_1	NOR2
xNOR2	VDD GROND NOR_out_1 Qreset_B NOR_out_2	NOR2
xNOR3	VDD GROND NOR_out_2 QB1 Q	NOR2
xNOT1	VDD	GROND	Q	QB	NOT
.ends

*******************************************************************

.subckt FE_RER_DFF_2 VDD GROND D	CLK	RESET	Q	QB		*falling edge CLK_rising edge reset_DFF
xFE_DFF1	VDD	GROND	D	CLK	Q_SR_latch#	Q	QB	FE_DFF
xFE_SR_latch1	VDD	GROND	CLK	RESET	Q_SR_latch	FE_SR_latch
xNOT1	VDD	GROND	Q_SR_latch	Q_SR_latch#	NOT
.ends

*******************************************************************

.subckt FE_RER_DFF_3 VDD GROND D	CLK	RESET	Q	QB		*falling edge CLK_rising edge reset_DFF
xFE_DFF1	VDD	GROND	D	CLK	Q_SR_latch#	Q	QB	FE_DFF
xFE_SR_latch1	VDD	GROND	CLK	RESET	Q_SR_latch	FE_SR_latch_2
xNOT1	VDD	GROND	Q_SR_latch	Q_SR_latch#1	NOT_delay
xNOT2	VDD	GROND	Q_SR_latch#1	Q_SR_latch1	NOT_delay
xNOT3	VDD	GROND	Q_SR_latch1	Q_SR_latch#	NOT_delay
*xNOT4	VDD	GROND	Q_SR_latch#2	Q_SR_latch2	NOT_delay
*xNOT5	VDD	GROND	Q_SR_latch2	Q_SR_latch#	NOT_delay
.ends

*******************************************************************

.subckt FE_SR_latch VDD GROND	SET	RESET	Q
xNOR1 VDD GROND	NOR3_out	Q		NOR1_out	NOR2
xNOR2 VDD GROND	NOR1_out	RESET	Q			NOR2

xNOT1 VDD GROND	SET		SET#1	NOT
xNOT2 VDD GROND	SET#1	SET2	NOT
xNOT3 VDD GROND	SET2	SET#2	NOT
xNOT4 VDD GROND	SET#2	SET3	NOT
xNOT5 VDD GROND	SET3	SET#3	NOT
xNOT6 VDD GROND	SET#3	SET4	NOT
xNOT7 VDD GROND	SET4	SET#4	NOT
xNOT8 VDD GROND	SET#4	SET5	NOT
xNOT9 VDD GROND	SET5	SET#5	NOT
xNOT10 VDD GROND	SET#5	SET6	NOT
xNOT11 VDD GROND	SET6	SET#6	NOT
xNOT12 VDD GROND	SET#6	SET7	NOT
xNOT13 VDD GROND	SET7	SET#7	NOT

xNOR3 VDD GROND	SET	SET#7	NOR3_out	NOR2

.ends

*******************************************************************

.subckt FE_SR_latch_2 VDD GROND	SET	RESET	Q						* FE set RE reset SR latch
xNOR1 VDD GROND	NOR3_out	Q		NOR1_out	NOR2
xNOR2 VDD GROND	NOR1_out	NAND1_out#	Q			NOR2

xNOT_SET_1 VDD GROND	SET		SET#1	NOT_delay
xNOT_SET_2 VDD GROND	SET#1	SET2	NOT_delay
xNOT_SET_3 VDD GROND	SET2	SET#2	NOT_delay
xNOT_SET_4 VDD GROND	SET#2	SET3	NOT
xNOT_SET_5 VDD GROND	SET3	SET#3	NOT
xNOT_SET_6 VDD GROND	SET#3	SET4	NOT
xNOT_SET_7 VDD GROND	SET4	SET#4	NOT
xNOT_SET_8 VDD GROND	SET#4	SET5	NOT
xNOT_SET_9 VDD GROND	SET5	SET#5	NOT
xNOT_SET_10 VDD GROND	SET#5	SET6	NOT
xNOT_SET_11 VDD GROND	SET6	SET#6	NOT
xNOT_SET_12 VDD GROND	SET#6	SET7	NOT
xNOT_SET_13 VDD GROND	SET7	SET#7	NOT
xNOT_SET_14 VDD GROND	SET#7	SET8	NOT
xNOT_SET_15 VDD GROND	SET8	SET#8	NOT
xNOT_SET_16 VDD GROND	SET#8	SET9	NOT
xNOT_SET_17 VDD GROND	SET9	SET#9	NOT
xNOT_SET_18 VDD GROND	SET#9	SET10	NOT
xNOT_SET_19 VDD GROND	SET10	SET#10	NOT
xNOT_SET_20 VDD GROND	SET#10	SET11	NOT
xNOT_SET_21 VDD GROND	SET11	SET#11	NOT

xNOT_RESET_1  VDD GROND	RESET		RESET#1	NOT
xNOT_RESET_2  VDD GROND	RESET#1	RESET2	NOT_delay
xNOT_RESET_3  VDD GROND	RESET2	RESET#2	NOT_delay
xNOT_RESET_4  VDD GROND	RESET#2	RESET3	NOT_delay
xNOT_RESET_5  VDD GROND	RESET3	RESET#3	NOT
xNOT_RESET_6  VDD GROND	RESET#3	RESET4	NOT
xNOT_RESET_7  VDD GROND	RESET4	RESET#4	NOT
xNOT_RESET_8  VDD GROND	RESET#4	RESET5	NOT
xNOT_RESET_9  VDD GROND	RESET5	RESET#5	NOT
xNOT_RESET_10 VDD GROND	RESET#5	RESET6	NOT
xNOT_RESET_11 VDD GROND	RESET6	RESET#6	NOT
xNOT_RESET_12 VDD GROND	RESET#6	RESET7	NOT
xNOT_RESET_13 VDD GROND	RESET7	RESET#7	NOT
xNOT_RESET_14 VDD GROND	RESET#7	RESET8	NOT
xNOT_RESET_15 VDD GROND	RESET8	RESET#8	NOT
xNOT_RESET_16 VDD GROND	RESET#8	RESET9	NOT
xNOT_RESET_17 VDD GROND	RESET9	RESET#9	NOT
xNOT_RESET_18 VDD GROND	RESET#9	RESET10	NOT
xNOT_RESET_19 VDD GROND	RESET10	RESET#10	NOT
xNOT_RESET_20 VDD GROND	RESET#10	RESET11	NOT
xNOT_RESET_21 VDD GROND	RESET11	RESET#11	NOT

xNOR3 VDD GROND	SET	SET#7	NOR3_out	NOR2
xNAND1 VDD GROND	RESET	RESET#11	NAND1_out	NAND2
xNOT35 VDD GROND	NAND1_out	NAND1_out#	NOT

.ends

*******************************************************************

.subckt MUX_1Bit VDD GROND	S A0 A1	OUT

xNOT1	VDD	GROND	S	S#	NOT

xNOT2 VDD GROND	A0	A0#	NOT
xNOT3 VDD GROND	A1	A1#	NOT

x1_D	A0#	S#	OUT#	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_D	OUT#	S	A0#	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'

x1_U	A1#	S	OUT#	GROND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'
x2_U	OUT#	S#	A1#	VDD	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='2.3*Wmin'	l='Lmin'

xNOT4 VDD GROND	OUT#	OUT	NOT

.ends

*******************************************************************

.subckt Interface_unit VDD GROND CLK	CS	RESET	OUT
xRE_DFF1	VDD GROND	CS	CLK	RESET	Q	RE_DFF
xNOT1 VDD GROND	CLK	OUT1	NOT
xNOT2 VDD GROND	OUT1	OUT2	NOT
xNAND1 VDD GROND	Q	OUT2	OUT	NAND2
.ends


*************************************	main circuit	********************************************
**************************************	Vlotage sources

V_VDD VDD_nod GND dc VDD
V_VDD_enhanced VDD_nod_enhanced GND dc VDD_enhanced
V_VDD_nominal	VDD_nominal_nod	GND	dc VDD_nominal
V_CLK CLK GND PULSE	0	VDD	'1*T_clk'		1p	1p	'0.5*T_clk'	'T_clk'
V_CS CS GND PULSE	0	VDD	'0.025*T_clk'	1p	1p	'T_simulation'	'T_simulation+T_clk'
*V_RWB RWB GND PULSE	VDD	0	'0.75*T_clk'	1p	1p	'T_clk'		'2*T_clk'
V_RWB RWB GND PULSE	VDD	0	'11.75*T_clk'	1p	1p	'T_clk'	'T_simulation'
V_GR GR GND PULSE	0	VDD	'0.5*T_clk'	1p	1p	'0.5*T_clk'		'T_simulation'
V_Write write GND PULSE	VDD	0	'T_simulation'	1p	1p	'T_clk'		'T_simulation'

V_dummy_WE dummy_WE GND dc 0
V_write_counter5#	write_counter5#	GND	PULSE	VDD	0	'2.75*T_clk'		1p	1p	'T_simulation'	'T_simulation+T_clk'
V_A0	A0	GND		dc	VDD
V_A1	A1	GND		dc	VDD
V_A2	A2	GND		dc	0
V_A3	A3	GND		dc	0

**************************************	main column

XSRAM1_main	VDD_nod GND WL BL BLB	SRAM_6T
XSRAM1_leak	VDD_nod GND GND BL_leak	BLB_leak	SRAM_6T
V_BL_leak	BL	BL_leak		dc	0
V_BLB_leak	BLB	BLB_leak	dc	0

XSA1_main VDD_nod GND BL BLB SE output	not_connect1_main sense_amp
*XSA2_main VDD_nod GND BLB BL SE output#	not_connect2_main sense_amp

XWD1_main VDD_nod GND BL BLB WE_gated write write_driver
xNOR1_main	VDD_nod	GND	WE	LCA	WE_gated	NOR2

*x1_main	BL	GND		VDD_nod VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'
x2_main	BL	PCB#	VDD_nod VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'
*x3_main	BLB	GND		VDD_nod VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'
x4_main	BLB	PCB#	VDD_nod VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'
x5_main	BL	PCB#	BLB VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='Lmin'

xTG1_BL_col_decoder	VDD	GND	BL	A1	BL_col_decoder1		TG
xTG2_BL_col_decoder	VDD	GND	BL_col_decoder1	A0	BL_col_decoder2		TG

xTG1_BLB_col_decoder	VDD	GND	BLB	A1	BLB_col_decoder1	TG
xTG2_BLB_col_decoder	VDD	GND	BLB_col_decoder1	A0	BLB_col_decoder2	TG

**************************************	dummy replica column

XSRAM1_dummy	VDD_nod GND dummy_WL dummy_BL dummy_BLB	SRAM_6T_NV
XWD2_dummy VDD_nod GND dummy_BL dummy_BLB dummy_WE GND write_driver

x1_dummy	dummy_BL	dummy_WL	VDD_nod		VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x2_dummy	dummy_BL	dummy_WL	dummy_BLB	VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x3_dummy	dummy_BLB	dummy_WL	VDD_nod		VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'

**************************************	timing circuit

xInterface_unit1_timing	VDD_nod	GND	CLK	CS	GND	START	Interface_unit
xFE_RER_DFF1_timing	VDD_nod	GND	RWB_gated		START	RESET	not_connect1_timing	SE	FE_RER_DFF_3
xFE_RER_DFF2_timing	VDD_nod	GND	RWB_gated#		START	RESET	not_connect2_timing	WE	FE_RER_DFF_3

*xNOR1_timing	VDD_nod	GND	LCA	LCP_1	LCP_2	LCF#	NOR3
*xNOT1_timing	VDD_nod	GND	LCF#	LCF	NOT
xNOR2_timing	VDD_nod	GND	RWB	PRE_LCA	RWB_gated#	NOR2
xNOT2_timing	VDD_nod	GND	RWB_gated#	RWB_gated	NOT

*xNOR3_timing	VDD_nod	GND	RESET	LCA	RESET_gated	NOR2
*xNOT3_timing	VDD_nod	GND	RESET_gated	RESET_gated#	NOT
xFE_SR_latch1_timing	VDD_nod	GND	START	RESET	dummy_WL	FE_SR_latch_2

xNOT4_timing	VDD_nod	GND	dummy_BL	dummy_BL#1	NOT_NV
xNOT5_timing	VDD_nod	GND	dummy_BL#1	dummy_BL1	NOT_NV
xNOT6_timing	VDD_nod	GND	dummy_BL1	RESET		NOT_NV

*xNOT7_timing	VDD_nod	GND	dummy_WL	dummy_WL_delay_1	NOT_delay
*xNOT8_timing	VDD_nod	GND	dummy_WL_delay_1	dummy_WL_delay	NOT_delay
xNOT9_timing	VDD_nod	GND	RWB	RWB#	NOT
xNOT10_timing	VDD_nod	GND	RWB	RWB#_delayed	NOT_delay
xNOR4_timing	VDD_nod	GND	RWB#_delayed	SE	SA_flag	NOR2
xNOR5_timing	VDD_nod	GND	dummy_WL	SA_flag	PCB	NOR2
xNOT11_timing	VDD_nod	GND	PCB	PCB#	NOT

x1_row_decoder_timing	d1_row_decoder	A3	VDD_nod		VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
x2_row_decoder_timing	d2_row_decoder	A2	VDD_nod		VDD_nod	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='7.7*Wmin'	l='Lmin'
xNAND1_timing	VDD_nod	GND	d1_row_decoder	d2_row_decoder	row_address_enable	NAND2
*xNOR6_timing	VDD_nod	GND	dummy_WL#	LCP_1	LCP_2	LCP_3	row_address_enable	WL	NOR5
xNOR6_timing	VDD_nod	GND	dummy_WL#	LCA		row_address_enable	WL	NOR3
xNOT12_timing	VDD_nod	GND	dummy_WL	dummy_WL#	NOT

**************************************	leakage compensation circuit

* xNOR1_leak	VDD_nod	GND	GND	CLK	write_counter1	NOR2					* notice
* xNOR2_leak	VDD_nod	GND	RWB	CLK	write_counter1	NOR2
* xNOT1_leak	VDD_nod	GND	write_counter1	write_counter1#	NOT


* xFE_DFF1_leak	VDD_nod	GND	write_counter2	write_counter1#	GND	write_counter2#_NC	write_counter2	FE_DFF
* xFE_DFF2_leak	VDD_nod	GND	write_counter3	write_counter2	GND	write_counter3#_NC	write_counter3	FE_DFF
* xFE_DFF3_leak	VDD_nod	GND	write_counter4	write_counter3	GND	write_counter4#_NC	write_counter4	FE_DFF
* xFE_DFF4_leak	VDD_nod	GND	write_counter5	write_counter4	GND	write_counter5#	write_counter5	FE_DFF
xFE_SR_latch1_leak	VDD_nod	GND	write_counter5#	LCP_RESET_GR	PRE_LCA	FE_SR_latch_2

xNOR1_GR_leak	VDD_nod	GND	LCA	GR	LCA_GR#	NOR2
xNOT1_GR_leak	VDD_nod	GND	LCA_GR#	LCA_GR	NOT
xNOR2_GR_leak	VDD_nod	GND	LCP_RESET	GR	LCP_RESET_GR#	NOR2
xNOT2_GR_leak	VDD_nod	GND	LCP_RESET_GR#	LCP_RESET_GR	NOT

xNOT3_leak	VDD_nod	GND	START	START#	NOT
xNAND1_leak	VDD_nod	GND	START#	LCA	START_LCA	NAND2

xFE_SR_latch2_leak	VDD_nod	GND	LCA		LCA_GR	LCA_down_flag	FE_SR_latch_2
xNOT4_leak	VDD_nod	GND	LCA_down_flag	LCA_down_flag#	NOT
xNAND2_leak	VDD_nod	GND	START	LCA		START_LCA_first#	NAND2
xNAND3_leak	VDD_nod	GND	LCA_down_flag#	START_LCA_first#	START_LCA_first_gated	NAND2

xFE_RER_DFF1_leak		VDD_nod	GND	PRE_LCA		START	LCP_RESET_GR	LCA		not_connect1_leak	FE_RER_DFF_3
xFE_RER_DFF2_leak		VDD_nod	GND	LCA		START_LCA_first_gated	LCA_GR			LCP_1	not_connect2_leak	FE_RER_DFF_3
xFE_RER_DFF3_leak		VDD_nod	GND	LCP_1	START_LCA	LCA_GR			LCP_2	not_connect3_leak	FE_RER_DFF_3
xFE_RER_DFF4_leak		VDD_nod	GND	LCP_2	START_LCA	LCA_GR			LCP_3	not_connect4_leak	FE_RER_DFF_3
xFE_RER_DFF5_leak		VDD_nod	GND	LCP_3	START_LCA	LCA_GR			LCP_4	not_connect5_leak	FE_RER_DFF_3
xFE_RER_DFF6_leak		VDD_nod	GND	LCP_4	START_LCA	LCA_GR			LCP_5	not_connect6_leak	FE_RER_DFF_3
xFE_RER_DFF7_leak		VDD_nod	GND	LCP_5	START_LCA	LCA_GR			LCP_6	not_connect7_leak	FE_RER_DFF_3
xFE_RER_DFF8_leak		VDD_nod	GND	LCP_6	START_LCA	LCA_GR			LCP_7	not_connect8_leak	FE_RER_DFF_3
xFE_RER_DFF9_leak		VDD_nod	GND	LCP_7	START_LCA	LCA_GR			LCP_8	not_connect9_leak	FE_RER_DFF_3
* xFE_RER_DFF10_leak	VDD_nod	GND	LCP_8	START_LCA	LCA_GR			LCP_9	not_connect10_leak	FE_RER_DFF_3
* xFE_RER_DFF11_leak	VDD_nod	GND	LCP_9	START_LCA	LCA_GR			LCP_10	not_connect11_leak	FE_RER_DFF_3
* xFE_RER_DFF12_leak	VDD_nod	GND	LCP_10	START_LCA	LCA_GR			LCP_11	not_connect12_leak	FE_RER_DFF_3
* xFE_RER_DFF13_leak	VDD_nod	GND	LCP_11	START_LCA	LCA_GR			LCP_12	not_connect13_leak	FE_RER_DFF_3
xFE_SR_latch3_leak	VDD_nod	GND	LCA		LCA_GR			PRE_LCP_excess_write	FE_SR_latch_2
xFE_RER_DFF15_leak	VDD_nod	GND	PRE_LCP_excess_write	START	LCA_GR		LCP_excess_write	not_connect14_leak	FE_RER_DFF_3



xNOT6_leak	VDD_nod	GND	SE	SE#1	NOT_delay
xNOT7_leak	VDD_nod	GND	SE	SE#		NOT
xNOT8_leak	VDD_nod	GND	SE#1	SE1	NOT_delay
xNOT9_leak	VDD_nod	GND	SE1		SE#2	NOT_delay
xNOT10_leak	VDD_nod	GND	SE#2	SE2	NOT_delay
xNOT11_leak	VDD_nod	GND	SE2	SE#_delayed	NOT_delay
xNOT12_leak	VDD_nod	GND	LCA	LCA#	NOT
xNOR4_leak	VDD_nod	GND	SE#_delayed	SE#		LCA#	LCP_1	leakage_compare_CLK	NOR4
xNOR5_leak	VDD_nod	GND	SE#_delayed	SE#		LCA#	current_compare_CLK	NOR3
xRE_DFF1_leak	VDD_nod GND	output	leakage_compare_CLK		GND	BL_leakage_greater#	RE_DFF
xRE_DFF2_leak	VDD_nod GND	output	current_compare_CLK		GND	current_compare_output	RE_DFF


xXOR1_leak	VDD_nod	GND	current_compare_output	BL_leakage_greater#	LCR	XOR2
xNAND4_leak	VDD_nod	GND	LCR	LCP_1	LCR_gated#	NAND2
xNOT13_leak	VDD_nod	GND	LCR_gated#	LCR_gated	NOT
xNOR6_leak	VDD_nod	GND	LCR_gated	LCP_8	LCP_RESET#	NOR2
xNOT14_leak	VDD_nod	GND	LCP_RESET#	LCP_RESET	NOT



xNOT20_leak	VDD_nod	GND	LCP_1	LCP_1#	NOT
xNOR7_leak	VDD_nod	GND	BL_leakage_greater#	LCP_1#	RWB#	BL_leakage_compensation_gated_1	NOR3
xNAND10_leak	VDD_nod	GND	BL_leakage_greater#	LCP_1	RWB	BLB_leakage_compensation_gated_1#	NAND3
xNOT21_leak	VDD_nod	GND	BLB_leakage_compensation_gated_1#	BLB_leakage_compensation_gated_1	NOT
xNOT22_leak	VDD_nod	GND	LCP_2	LCP_2#	NOT
xNOR8_leak	VDD_nod	GND	BL_leakage_greater#	LCP_2#	RWB#	BL_leakage_compensation_gated_2	NOR3
xNAND11_leak	VDD_nod	GND	BL_leakage_greater#	LCP_2	RWB	BLB_leakage_compensation_gated_2#	NAND3
xNOT23_leak	VDD_nod	GND	BLB_leakage_compensation_gated_2#	BLB_leakage_compensation_gated_2	NOT
xNOT24_leak	VDD_nod	GND	LCP_3	LCP_3#	NOT
xNOR9_leak	VDD_nod	GND	BL_leakage_greater#	LCP_3#	RWB#	BL_leakage_compensation_gated_3	NOR3
xNAND12_leak	VDD_nod	GND	BL_leakage_greater#	LCP_3	RWB	BLB_leakage_compensation_gated_3#	NAND3
xNOT25_leak	VDD_nod	GND	BLB_leakage_compensation_gated_3#	BLB_leakage_compensation_gated_3	NOT
xNOT26_leak	VDD_nod	GND	LCP_4	LCP_4#	NOT
xNOR10_leak	VDD_nod	GND	BL_leakage_greater#	LCP_4#	RWB#	BL_leakage_compensation_gated_4	NOR3
xNAND13_leak	VDD_nod	GND	BL_leakage_greater#	LCP_4	RWB	BLB_leakage_compensation_gated_4#	NAND3
xNOT27_leak	VDD_nod	GND	BLB_leakage_compensation_gated_4#	BLB_leakage_compensation_gated_4	NOT
xNOT28_leak	VDD_nod	GND	LCP_5	LCP_5#	NOT
xNOR11_leak	VDD_nod	GND	BL_leakage_greater#	LCP_5#	RWB#	BL_leakage_compensation_gated_5	NOR3
xNAND14_leak	VDD_nod	GND	BL_leakage_greater#	LCP_5	RWB	BLB_leakage_compensation_gated_5#	NAND3
xNOT29_leak	VDD_nod	GND	BLB_leakage_compensation_gated_5#	BLB_leakage_compensation_gated_5	NOT
xNOT30_leak	VDD_nod	GND	LCP_6	LCP_6#	NOT
xNOR12_leak	VDD_nod	GND	BL_leakage_greater#	LCP_6#	RWB#	BL_leakage_compensation_gated_6	NOR3
xNAND15_leak	VDD_nod	GND	BL_leakage_greater#	LCP_6	RWB	BLB_leakage_compensation_gated_6#	NAND3
xNOT31_leak	VDD_nod	GND	BLB_leakage_compensation_gated_6#	BLB_leakage_compensation_gated_6	NOT
xNOT32_leak	VDD_nod	GND	LCP_7	LCP_7#	NOT
xNOR13_leak	VDD_nod	GND	BL_leakage_greater#	LCP_7#	RWB#	BL_leakage_compensation_gated_7	NOR3
xNAND16_leak	VDD_nod	GND	BL_leakage_greater#	LCP_7	RWB	BLB_leakage_compensation_gated_7#	NAND3
xNOT33_leak	VDD_nod	GND	BLB_leakage_compensation_gated_7#	BLB_leakage_compensation_gated_7	NOT
xNOT34_leak	VDD_nod	GND	LCP_8	LCP_8#	NOT
xNOR14_leak	VDD_nod	GND	BL_leakage_greater#	LCP_8#	RWB#	BL_leakage_compensation_gated_8	NOR3
xNAND17_leak	VDD_nod	GND	BL_leakage_greater#	LCP_8	RWB	BLB_leakage_compensation_gated_8#	NAND3
xNOT35_leak	VDD_nod	GND	BLB_leakage_compensation_gated_8#	BLB_leakage_compensation_gated_8	NOT
* xNOT36_leak	VDD_nod	GND	LCP_9	LCP_9#	NOT
* xNOR15_leak	VDD_nod	GND	BL_leakage_greater#	LCP_9#	RWB#	BL_leakage_compensation_gated_9	NOR3
* xNAND18_leak	VDD_nod	GND	BL_leakage_greater#	LCP_9	RWB	BLB_leakage_compensation_gated_9#	NAND3
* xNOT37_leak	VDD_nod	GND	BLB_leakage_compensation_gated_9#	BLB_leakage_compensation_gated_9	NOT
* xNOT38_leak	VDD_nod	GND	LCP_10	LCP_10#	NOT
* xNOR16_leak	VDD_nod	GND	BL_leakage_greater#	LCP_10#	RWB#	BL_leakage_compensation_gated_10	NOR3
* xNAND19_leak	VDD_nod	GND	BL_leakage_greater#	LCP_10	RWB	BLB_leakage_compensation_gated_10#	NAND3
* xNOT39_leak	VDD_nod	GND	BLB_leakage_compensation_gated_10#	BLB_leakage_compensation_gated_10	NOT
* xNOT40_leak	VDD_nod	GND	LCP_11	LCP_11#	NOT
* xNOR17_leak	VDD_nod	GND	BL_leakage_greater#	LCP_11#	RWB#	BL_leakage_compensation_gated_11	NOR3
* xNAND20_leak	VDD_nod	GND	BL_leakage_greater#	LCP_11	RWB	BLB_leakage_compensation_gated_11#	NAND3
* xNOT41_leak	VDD_nod	GND	BLB_leakage_compensation_gated_11#	BLB_leakage_compensation_gated_11	NOT
* xNOT42_leak	VDD_nod	GND	LCP_12	LCP_12#	NOT
* xNOR18_leak	VDD_nod	GND	BL_leakage_greater#	LCP_12#	RWB#	BL_leakage_compensation_gated_12	NOR3
* xNAND21_leak	VDD_nod	GND	BL_leakage_greater#	LCP_12	RWB	BLB_leakage_compensation_gated_12#	NAND3
* xNOT43_leak	VDD_nod	GND	BLB_leakage_compensation_gated_12#	BLB_leakage_compensation_gated_12	NOT

xNOT42_leak	VDD_nod	GND	LCP_excess_write	LCP_excess_write#	NOT
xNOR19_leak	VDD_nod	GND	BL_leakage_greater#	LCP_excess_write#	BL_excess_write_leakage_gated	NOR2
xNAND22_leak	VDD_nod	GND	BL_leakage_greater#	LCP_excess_write	BLB_excess_write_leakage_gated#	NAND2
xNOT43_leak	VDD_nod	GND	BLB_excess_write_leakage_gated#	BLB_excess_write_leakage_gated	NOT


* x1_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x1_leakage_2	D_M1_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x1_leakage_2	D_M1_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
V_D_M1_leakage_0v	D_M1_leakage 	D_M1_leakage_0v dc 0
x1_BL_leakage	BL	BLB_leakage_compensation_gated_1		D_M1_leakage_0v	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x1_BLB_leakage	BLB	BL_leakage_compensation_gated_1		D_M1_leakage_0v	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x2_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x2_leakage_2	D_M2_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x2_leakage_2	D_M2_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x2_BL_leakage	BL	BLB_leakage_compensation_gated_2		D_M2_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x2_BLB_leakage	BLB	BL_leakage_compensation_gated_2		D_M2_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x3_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x3_leakage_2	D_M3_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x3_leakage_2	D_M3_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x3_BL_leakage	BL	BLB_leakage_compensation_gated_3		D_M3_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x3_BLB_leakage	BLB	BL_leakage_compensation_gated_3		D_M3_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x4_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x4_leakage_2	D_M4_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x4_leakage_2	D_M4_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x4_BL_leakage	BL	BLB_leakage_compensation_gated_4		D_M4_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x4_BLB_leakage	BLB	BL_leakage_compensation_gated_4		D_M4_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x5_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x5_leakage_2	D_M5_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x5_leakage_2	D_M5_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x5_BL_leakage	BL	BLB_leakage_compensation_gated_5		D_M5_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x5_BLB_leakage	BLB	BL_leakage_compensation_gated_5		D_M5_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x6_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x6_leakage_2	D_M6_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x6_leakage_2	D_M6_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x6_BL_leakage	BL	BLB_leakage_compensation_gated_6		D_M6_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x6_BLB_leakage	BLB	BL_leakage_compensation_gated_6		D_M6_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x7_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x7_leakage_2	D_M7_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x7_leakage_2	D_M7_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x7_BL_leakage	BL	BLB_leakage_compensation_gated_7		D_M7_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x7_BLB_leakage	BLB	BL_leakage_compensation_gated_7		D_M7_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x8_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x8_leakage_2	D_M8_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x8_leakage_2	D_M8_leakage	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
x8_BL_leakage	BL	BLB_leakage_compensation_gated_8		D_M8_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
x8_BLB_leakage	BLB	BL_leakage_compensation_gated_8		D_M8_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x9_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x9_leakage_2	D_M9_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x9_BL_leakage	BL	BLB_leakage_compensation_gated_9		D_M9_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x9_BLB_leakage	BLB	BL_leakage_compensation_gated_9		D_M9_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x10_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x10_leakage_2	D_M10_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x10_BL_leakage	BL	BLB_leakage_compensation_gated_10		D_M10_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x10_BLB_leakage	BLB	BL_leakage_compensation_gated_10		D_M10_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x11_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x11_leakage_2	D_M11_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x11_BL_leakage	BL	BLB_leakage_compensation_gated_11		D_M11_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x11_BLB_leakage	BLB	BL_leakage_compensation_gated_11		D_M11_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x12_leakage_1	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x12_leakage_2	D_M12_leakage	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x12_BL_leakage	BL	BLB_leakage_compensation_gated_12		D_M12_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'
* x12_BLB_leakage	BLB	BL_leakage_compensation_gated_12		D_M12_leakage	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='20*Wmin'	l='2*Lmin'


x1_BL_excess_write_leakage	CS_nod_excess_write_BL		CS_nod_excess_write_BL		GND		GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='28*Wmin'	l='10*Lmin'
x2_BL_excess_write_leakage	D_M_excess_write_leakage_BL		CS_nod_excess_write_BL		GND		GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'
x_BL_excess_write_leakage		BL	BLB_excess_write_leakage_gated		D_M_excess_write_leakage_BL	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'


* x1_BLB_excess_write_leakage	CS_nod_excess_write_BLB		CS_nod_excess_write_BLB		GND		GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='28*Wmin'	l='10*Lmin'
* x2_BLB_excess_write_leakage	D_M_excess_write_leakage_BLB		CS_nod_excess_write_BLB		GND		GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'
* x_BLB_excess_write_leakage	BLB	BL_excess_write_leakage_gated		D_M_excess_write_leakage_BLB	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'


*Fcccs_BLB_leak_comp	CS_dummy_leak	GND		V_BL_leak	n_sink
I_leak_comp				CS_dummy_leak_0v 	GND		I_dummy_leak_120_gauss
V_leak_comp_0v CS_dummy_leak CS_dummy_leak_0v dc 0
*I_leak_comp			CS_dummy_leak 	GND		0

x1_dummy_leak	CS_dummy_leak	CS_dummy_leak	VDD_nod_enhanced		VDD_nod_enhanced	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='100*Wmin'	l='10*Lmin'
x2_dummy_leak	out1_dummy_leak_0v	CS_dummy_leak	VDD_nod_enhanced		VDD_nod_enhanced	pch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='17*Wmin'	l='10*Lmin'
V_dummy_leak_0v out1_dummy_leak out1_dummy_leak_0v dc 0
x3_dummy_leak	out1_dummy_leak	out1_dummy_leak	GND	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x4_dummy_leak	D_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x5_dummy_leak	G_M4_dummy_leak	G_M4_dummy_leak	GND		GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'
* x6_dummy_leak	CS_nod	out1_dummy_leak	G_M4_dummy_leak	GND	nch_mac totalflag=total_flag globalflag=global_flag mismatchflag=mismatch_flag	w='10*Wmin'	l='10*Lmin'

*Fcccs_excess_write_leak	VDD_nod	CS_nod_excess_write_BL		V_BL_leak	'2*nint-2'
I_excess_write_leak	VDD_nod	CS_nod_excess_write_BL		I_leak_excess_write_120_gauss
*Fcccs_precision_leak	VDD_nod	CS_nod_excess_write_BL		V_BL_leak	'0.5*n_sink'
*I_precision_leak	VDD_nod	CS_nod_excess_write_BL		I_leak_precision_120_gauss

*Fcccs_excess_write_leak	VDD_nod	CS_nod_excess_write_BLB		V_BL_leak	'2*nint-2'
*I_excess_write_leak	VDD_nod	CS_nod_excess_write_BLB		I_leak_excess_write_120_gauss
*Fcccs_precision_leak	VDD_nod	CS_nod_excess_write_BLB		V_BL_leak	'0.5*n_sink'
*I_precision_leak	VDD_nod	CS_nod_excess_write_BLB		I_leak_precision_120_gauss


* I_leak_BL	VDD_nod		CS_node_leak_BL		dc		I_leak_BL_120_gauss
* I_leak_BLB	VDD_nod		CS_node_leak_BLB	dc		I_leak_BLB_120_gauss
* x1_leak_BL	CS_node_leak_BL_0v	CS_node_leak_BL_0v	GND	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='26*Wmin'	l='10*Lmin'
* x2_leak_BL	BL_0v	CS_node_leak_BL_0v	GND	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'
* x1_leak_BLB	CS_node_leak_BLB_0v	CS_node_leak_BLB_0v	GND	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='26*Wmin'	l='10*Lmin'
* x2_leak_BLB	BLB_0v	CS_node_leak_BLB_0v	GND	GND	nch_mac totalflag=total_flag_NV globalflag=global_flag mismatchflag=mismatch_flag	w='23*Wmin'	l='10*Lmin'
* V_leak_BLB_0v 	BLB BLB_0v dc 0
* V_CS_node_leak_BLB_0v CS_node_leak_BLB CS_node_leak_BLB_0v dc 0
* V_leak_BL_0v 	BL BL_0v dc 0
* V_CS_node_leak_BL_0v CS_node_leak_BL CS_node_leak_BL_0v dc 0

**************************************	other elements

C1	BL	GND	C_BL
C2	BLB	GND	C_BL
*C3	WL	GND	C_WL

C1_dummy	dummy_BL	GND	'0.3*C_BL'
C2_dummy	dummy_BLB	GND	'0.3*C_BL'

C1_leak_dummy	leak_dummy_BL	GND		C_BL
C2_leak_dummy	leak_dummy_BLB	GND		C_BL

I_leak_BL		BL		GND	dc			I_leak_BL_120_gauss
I_leak_BLB		BLB		GND	dc			I_leak_BLB_120_gauss
*Fcccs_leak_BL	BL		GND	V_BL_leak	N0
*Fcccs_leak_BLB	BLB		GND	V_BL_leak	'nt-N0'

*I_leak_dummy_BL		dummy_BL	GND	dc	I_leak_BL_120_gauss
*I_leak_dummy_BLB		dummy_BLB	GND	dc	I_leak_BLB_120_gauss
*Fcccs_leak_dummy_BL	dummy_BL	GND	V_BL_leak	N0
*Fcccs_leak_dummy_BLB	dummy_BLB	GND	V_BL_leak	'nt-N0'


***********************************	output setting	**********************************************

*.dc temp -40 120 1
*.dc VDD 1.62 1.98 0.01
*.print	dc	V(output)
*.probe	gain=deriv( ' V(output) ' )
*.print	gain=par('V(output)')
*.measure ac fu when v(output)=1
*.MEAS TRAN output_max MAX V(output,GND) FROM=70ns TO=85ns
*.MEAS TRAN BL_leakage_compensation_gated FIND V(BL_leakage_compensation_gated) AT=T_sampling
*.MEAS TRAN BLB_leakage_compensation_gated FIND V(BLB_leakage_compensation_gated) AT=T_sampling
*.MEAS TRAN difference_max MAX V(BL,BLB) FROM=40ns TO=41ns
*.MEAS TRAN difference_min MIN V(BL,BLB) FROM=40ns TO=41ns
.op
.IC	V(XSRAM1_main.Q) 0 V(XSRAM1_main.QB) VDD	V(XSRAM1_dummy.Q) 0	V(XSRAM1_dummy.QB) VDD	V(XSRAM1_leak.Q)	0	V(XSRAM1_leak.QB)	VDD
+ V(BL)	VDD	V(BLB)	VDD	
+ V(START)	VDD		V(START_LCA)	VDD		V(RESET)	0	V(dummy_WL)	0	V(WE)	VDD		V(SE)	VDD
+ V(BL_leakage_compensation_gated_1)	0	V(BLB_leakage_compensation_gated_1)	0
+ V(BL_leakage_compensation_gated_2)	0	V(BLB_leakage_compensation_gated_2)	0
+ V(BL_leakage_compensation_gated_3)	0	V(BLB_leakage_compensation_gated_3)	0
+ V(BL_leakage_compensation_gated_4)	0	V(BLB_leakage_compensation_gated_4)	0
+ V(BL_leakage_compensation_gated_5)	0	V(BLB_leakage_compensation_gated_5)	0
+ V(BL_leakage_compensation_gated_6)	0	V(BLB_leakage_compensation_gated_6)	0
+ V(BL_leakage_compensation_gated_7)	0	V(BLB_leakage_compensation_gated_7)	0
+ V(BL_leakage_compensation_gated_8)	0	V(BLB_leakage_compensation_gated_8)	0
+ V(BL_leakage_compensation_gated_9)	0	V(BLB_leakage_compensation_gated_9)	0
+ V(BL_leakage_compensation_gated_10)	0	V(BLB_leakage_compensation_gated_10)	0
+ V(BL_leakage_compensation_gated_11)	0	V(BLB_leakage_compensation_gated_11)	0
+ V(BL_leakage_compensation_gated_12)	0	V(BLB_leakage_compensation_gated_12)	0
+ V(write_counter1)	VDD	V(write_counter2#_NC)	VDD	V(write_counter2)	0	V(write_counter3#_NC)	VDD	V(write_counter3)	0
+ V(write_counter4#_NC)	VDD	V(write_counter4)	0	*	V(write_counter5#)	VDD	V(write_counter5)	0
+ V(PRE_LCA)	VDD		V(LCA)	0	V(LCP_1)	0	V(LCP_2)	0	V(LCP_3)	0	V(LCP_4)	0	V(LCP_5)	0	V(LCP_6)	0
+ V(LCP_7)	0	V(LCP_8)	0	V(LCP_9)	0	V(LCP_10)	0	V(LCP_11)	0	V(LCP_12)	0	V(LCP_RESET)	VDD		V(LCR)	0
+ V(leakage_compare_CLK)	VDD	V(current_compare_CLK)	VDD	V(BL_leakage_greater#)	VDD	V(current_compare_output)	VDD
+ V(PRE_LCP_excess_write)	0	V(LCP_excess_write)	0

.TRAN	STEP=step_simulation	STOP=T_simulation	START=0n	 UIC SWEEP MONTE=MC_num
***********************************	end of simulation	**********************************************
.end