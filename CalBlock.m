classdef CalBlock < RexBlock
	%% calibration task
	
	properties ( SetAccess = public, GetAccess = public )
		blockType = 'Calibration Task';
		set_points = [];
		recorded_points = [];
	end

	methods
		%% CalBlock: function description
		function obj = CalBlock( blockName, data, dataSrc, fieldsFlag )
			if( nargin() < 1 )
				blockName = [];
			end
			if( nargin() <= 1 )
				data = [];
			end
			if( nargin() <= 2 )
				dataSrc = RexBlock.REFINED_FILE;
			end
			if( nargin() <= 3 )
				fieldsFlag = DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX + DATA_FIELD_FLAG.EYETRACE;
            end

			obj = obj@RexBlock( blockName, data, dataSrc, fieldsFlag );

			if( isempty( obj.trials ) )
				return;
			end

			%% calibration task specified code
			for( i = 1 : obj.nTrials )
				switch( obj.trials(i).type )
					case { TRIAL_TYPE_DEF.CORRECT, TRIAL_TYPE_DEF.ERROR }
						if( size(obj.trials(i).fp,2) ~= 1 || obj.trials(i).fp.tOn < 0 || obj.trials(i).fp.nPats ~= 1 ||...
							size(obj.trials(i).rf,2) ~= 1 || obj.trials(i).rf.tOn >= 0 ||...
							size(obj.trials(i).rf2,2) ~= 1 || obj.trials(i).rf2.tOn >= 0 ||...
							size(obj.trials(i).cue,2) ~= 1 || obj.trials(i).cue.tOn >= 0 ||...
							size(obj.trials(i).cue2,2) ~= 1 || obj.trials(i).cue2.tOn >= 0 ||...
							size(obj.trials(i).jmp1,2) ~= 1 || obj.trials(i).jmp1.tOn >= 0 ||...
							size(obj.trials(i).jmp2,2) ~= 1 || obj.trials(i).jmp2.tOn >= 0 )

							if( obj.trials(i).type == TRIAL_TYPE_DEF.CORRECT )
								obj.nCorrect = obj.nCorrect - 1;
								fprintf( 'Trial Index: %5d correct but unknown!\n', obj.trials(i).trialIndex );
							else
								obj.nError = obj.nError - 1;
								fprintf( 'Trial Index: %5d error but unknown!\n', obj.trials(i).trialIndex );
							end
							obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
							obj.nUnknown = obj.nUnknown + 1;
						end						

					case TRIAL_TYPE_DEF.FIXBREAK
						[ tBreak, breakSac ] = obj.trials(i).GetBreak();
						if( size(obj.trials(i).fp,2) ~= 1 || ( obj.trials(i).fp.tOn >= 0 && obj.trials(i).fp.nPats ~= 1 ) ||...
							size(obj.trials(i).rf,2) ~= 1 || obj.trials(i).rf.tOn >= 0 ||...
							size(obj.trials(i).rf2,2) ~= 1 || obj.trials(i).rf2.tOn >= 0 ||...
							size(obj.trials(i).cue,2) ~= 1 || obj.trials(i).cue.tOn >= 0 ||...
							size(obj.trials(i).cue2,2) ~= 1 || obj.trials(i).cue2.tOn >= 0 ||...
							size(obj.trials(i).jmp1,2) ~= 1 || obj.trials(i).jmp1.tOn >= 0 ||...
							size(obj.trials(i).jmp2,2) ~= 1 || obj.trials(i).jmp2.tOn >= 0 ||...
							tBreak < 0 || isempty(breakSac.latency) )

							obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
							obj.nFixbreak = obj.nFixbreak - 1;
							obj.nUnknown  = obj.nUnknown + 1;
							fprintf( 'Trial Index: %5d break but unknown!\n', obj.trials(i).trialIndex );						
						end

					case { TRIAL_TYPE_DEF.ABORT, TRIAL_TYPE_DEF.UNKNOWN }
						;

					otherwise
						obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
						obj.nUnknown = obj.nUnknown + 1;
				end
			end

			%% computation for the calibration control points
			trials = obj.trials( [obj.trials.type] == TRIAL_TYPE_DEF.CORRECT );
            if( isempty(trials) )
                disp( 'No correct trials!' );
                return;
            end
			fp = [trials.fp];
			[ obj.set_points, ~, index ] = unique( [ fp.x; fp.y ]', 'rows' );
			obj.recorded_points = zeros( size(obj.set_points) );
			for( i = 1 : size(obj.set_points,1) )
				ts = trials( index == i );
				points = zeros( size(ts,2), 2, 100 );
				for( iTrial = 1 : size(ts,2) )
					rwtime = ts(iTrial).evnts( 1, ts(iTrial).evnts(2,:) == REX_CODE_MAP.REWARD );
					ind = round( ( rwtime - 50 ) / 1000 * ts(iTrial).a2dRate );	% 100ms before reward
					points( iTrial, 1, : ) = ts(iTrial).eyeTrace.x( ind : ind+99 );
					points( iTrial, 2, : ) = ts(iTrial).eyeTrace.y( ind : ind+99 );
				end
				obj.recorded_points( i, : ) = median( median( points, 3 ), 1 );
			end

		end
	end
end