classdef TRIAL_TYPE_DEF
	properties (Constant)
		CORRECT		= 'c';	% correct
		ERROR		= 'e';	% error
		FIXBREAK	= 'b';	% fix break
		ABORT		= 'a';	% abort
		UNKNOWN 	= 'x';	% abnormal
	end
	methods ( Access = private )
		function obj = TRIAL_TYPE_DEF()
		end
	end
end