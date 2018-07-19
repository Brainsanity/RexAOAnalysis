classdef MK_CONSTANTS
	properties (Constant)
		TIME_UNIT	= 1;	% time unit: 1 for second
		A2DRATE		= 1000;	% REX sampling rate
		TRIAL_DUR_MAX = 6 * MK_CONSTANTS.TIME_UNIT;	% max trial duration
		RESPONSE_AMPLITUDE_MIN1 = 5;	% minimum saccade amplitude to detect the 1st response saccade
		RESPONSE_AMPLITUDE_MIN2 = 5;	% minimum saccade amplitude to detect the 2nd response saccade
		RESPONSE_BEFORE_JMP1 = 0.15 * MK_CONSTANTS.TIME_UNIT; 	% start time point before jmp1 to look for the 1st response saccade in milliseconds
		RESPONSE_BEFORE_JMP2 = 0.15 * MK_CONSTANTS.TIME_UNIT; 	% start time point before jmp2 to look for the 2nd response saccade in milliseconds

		AO_AI_RATE = 2790.1785;	% Alpha&Omega: general purpose analog input sampling rate in Hz
		AO_AO_RATE = 44642.857;	% Alpha&Omega: general purpose analog output sampling rate in Hz
		AO_HS_RATE = 44642.857;	% Alpha&Omega: headstage sampling rate in Hz
		AO_DI_RATE = 44642.857;	% Alpha&Omega: digital input sampling rate in Hz
	end
	methods ( Access = private )
		function obj = MK_CONSTANTS()
		end
	end
end