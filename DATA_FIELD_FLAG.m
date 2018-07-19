classdef DATA_FIELD_FLAG
	properties (Constant)
		EYETRACE		= uint32(1);
		LFP				= uint32(2);
		EVENTS			= uint32(4);
		SACCADES		= uint32(8);
		RESPONSE_INDEX	= uint32(16);
	end
	methods ( Access = private )
		function obj = DATA_FIELD_FLAG()
		end
	end
end