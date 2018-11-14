classdef ToolKit
	methods ( Access = private )
		function obj = ToolKit()
		end
	end

	methods ( Static )
		function h = BorderText( varargin )
			% Usage:
			%       htext = ToolKit.BorderText( 'Position', 'YourText');
			%       htext = ToolKit.BorderText( 'Position', 'YourText', '[FormatString]' );
			%       htext = ToolKit.BorderText( 'Position', 'YourText', 'Prop1', Value1, 'Prop2', Value2, ... );
			%
			%       run 'ToolKit.BorderText' without arguments to see an example.
			%   
			% Position:
			%                'topleft'           'top'          'topright'
			%       'lefttop'|-------------------------------------------|'righttop'
			%                |                                           |
			%          'left'|                  'center'                 |'right'
			%                |                                           |
			%    'leftbottom'|-------------------------------------------|'rightbottom'
			%                'bottomleft'       'bottom'     'bottomright'
			% 
			%       This 'Position'-string can be prefixed with 'inner' or 'figure'.
			%       e.g: 'innertopleft' or 'figurebottomright'
			%
			%       'Position' can also be an [ X Y ]-position wrt the current axis.
			%
			% Text:
			%   Your own string:    'Hello world'
			%   or with more lines: 'Hello World\nNice weather\nisn''t it?'
			%   or with more lines: {'Hello World','Nice weather','isn''t it?'}
			%
			% FormatString:
			%   FontSize:           [%f] (any positive floatingpoint value)
			%   TextZoom:           [ Z] Text zooms when zooming your plot (only when'Position' is an [ X Y ]-position)
			%   FontAttributes:      [B]  [I]  [L]  [T] (Bold, Italic, Latex, Tex)
			%   FontColors:          [w]  [k]  [r]  [g]  [b]  [c]  [m]  [y]
			%   FontColors:         [fw] [fk] [fr] [fg] [fb] [fc] [fm] [fy]
			%   BackgroundColors:   [bw] [bk] [br] [bg] [bb] [bc] [bm] [by]
			%   EdgeColors:         [ew] [ek] [er] [eg] [eb] [ec] [em] [ey]
			%   TextRotation:       [R%f] (any floatingpoint value)    
			%   HorizontalAlignment:[Hl] [Hc] [Hr]  (normally you don't need these)
			%   VerticalAlignment:  [Vb] [Vm] [Vt]  (normally you don't need these)
			%
			%   Examples:
			%     ToolKit.BorderText( 'innertopleft', '1^r^s^t line\n2^n^d line', '[B][I][T][fr][bg][ek][14][R10]' );
			%     ToolKit.BorderText( 'innertopleft', '1^r^s^t line\n2^n^d line', 'B I T fr bg ek 14 R10' );
			%     ToolKit.BorderText( [0.5 0.5], 'TextZoom', 'TextZoom', 'on' );
			%
			% Example with matlab syntax:
			%   ToolKit.BorderText( 'innertopleft', {'1^r^s^t line','2^n^d line'}, ...
			%     'FontWeight', 'Bold', 'FontAngle', 'Italic', 'Interpret', 'Tex', ...
			%     'Color', 'r', 'BackgroundColor', 'g', 'EdgeColor', [0 0 0], ...
			%     'FontSize', 14, 'Rotation', 10 );
			%      
			% To remove a BorderText-string from the figure:
			%   ToolKit.BorderText( <POSITION> , '' );   example: ToolKit.BorderText( 'innertopleft', '' );
			%
			% Last release:
			% V 3.00  30-aug-2014  Case-insensitive property 'FontSize'
			%                      Made to be a member function of the class ToolKit
			%
			% Author: Jan G. de Wilde   email: jan.dewilde@nl.thalesgroup.com
			%         Thales Nederland B.V.
			%         YB

			% V 1.00  22-sep-2006  First release.
			% V 2.00  01-apr-2013  Text stays on axis, also while zooming, panning or resizing.
			% V 2.01  04-apr-2013  Fix for reverse X- and Y-axes.
			% V 2.02  05-apr-2013  Some bugfixes.
			% V 2.03  10-apr-2013  More flexible in interpreting 'FormatString'.
			% V 2.04  12-apr-2013  Now able to handle linked-axes.
			% V 2.05  16-apr-2013  Make '[ X Y ]'-text invisible outside axis.
			% V 2.06  10-sep-2013  Support matlab syntax: ToolKit.BorderText( 'top', 'hello', 'Color', [1 0 0], 'FontSize', 20 );
			%                      text.Margin = eps; coloured background looks nicer.
			% V 2.07  25-feb-2014  Minor changes.
			% V 2.08  27-may-2014  Option to 'zoom' your text (only when'Position' is an [ X Y ]-position)
			%                      Use 'Clipping' to 'on' for 'userdefined'-text.
			% V 3.00  30-aug-2014  Case-insensitive property 'FontSize'
			%                      Made to be a member function of the class ToolKit

			VERSION = ToolKit.BorderText_GetVersion( mfilename('fullpath') );  % V 2.07

			if nargin == 0, % Help, Test and Debug mode
				help ToolKit.BorderText

				figure(999);	clf('reset');
				plot( randn(1,100), '+', 'MarkerSize', 4 );	axis([ 0 100 -3 3 ]);   pan on;
				%set(gca,'XDir','reverse');   set(gca,'YDir','reverse');
				%imagesc(rand(25),[-1 1]); colormap(gray); axis auto tight square
				title('title');   xlabel('xlabel');   ylabel('ylabel');

				ToolKit.BorderText('topleft','topleft');
				ToolKit.BorderText('top','top');
				ToolKit.BorderText('topright','topright');
				ToolKit.BorderText('righttop','righttop');
				ToolKit.BorderText('right','right');
				ToolKit.BorderText('rightbottom','rightbottom');
				ToolKit.BorderText('bottomright','bottomright');
				ToolKit.BorderText('bottom','bottom');
				ToolKit.BorderText('bottomleft','bottomleft');
				ToolKit.BorderText('leftbottom','leftbottom');
				ToolKit.BorderText('left','left');
				ToolKit.BorderText('lefttop','lefttop');
				ToolKit.BorderText('center','center');

				ToolKit.BorderText('innertopleft','innertopleft');
				ToolKit.BorderText('innertop','innertop');
				ToolKit.BorderText('innertopright','innertopright');
				ToolKit.BorderText('innerrighttop','innerrighttop');
				ToolKit.BorderText('innerright','innerright');
				ToolKit.BorderText('innerrightbottom','innerrightbottom');
				ToolKit.BorderText('innerbottomright','innerbottomright');
				ToolKit.BorderText('innerbottom','innerbottom');
				ToolKit.BorderText('innerbottomleft','innerbottomleft');
				ToolKit.BorderText('innerleftbottom','innerleftbottom');
				ToolKit.BorderText('innerleft','innerleft');
				ToolKit.BorderText('innerlefttop','innerlefttop');

				ToolKit.BorderText('figuretopleft','figuretopleft');
				ToolKit.BorderText('figuretop','figuretop');
				ToolKit.BorderText('figuretopright','figuretopright');
				ToolKit.BorderText('figurerighttop','figurerighttop');
				ToolKit.BorderText('figureright','figureright');
				ToolKit.BorderText('figurerightbottom','figurerightbottom');
				ToolKit.BorderText('figurebottomright','figurebottomright');
				ToolKit.BorderText('figurebottom','figurebottom');
				ToolKit.BorderText('figurebottomleft','figurebottomleft');
				ToolKit.BorderText('figureleftbottom','figureleftbottom');
				ToolKit.BorderText('figureleft','figureleft');
				ToolKit.BorderText('figurelefttop','figurelefttop');
				ToolKit.BorderText('figurecenter','figurecenter');

				ToolKit.BorderText([50  2.0],'h = ToolKit.BorderText( ''Position'', ''Text'' [,''FormatString'' ]);','[r][13][Z][Hc]');
				ToolKit.BorderText([50  1.5],'h = ToolKit.BorderText( ''Position'', ''Text'' [,''Property1'', Value1, ... ]);','[r][12][Z][Hc]');
				ToolKit.BorderText([50 -2.0], VERSION,'[m][13][Hc][Z]');

				return;
			end

			ax      = axis;
			curr_ax = gca;
			fnr     = gcf;
			Xrev    = strcmp( get( curr_ax, 'XDir' ), 'reverse' );   % V 2.01
			Yrev    = strcmp( get( curr_ax, 'YDir' ), 'reverse' );

			% Parse inputs
			if nargin >= 1, pos         = lower(varargin{1});  end
			if nargin >= 2, txt         = varargin{2};  end
			if nargin == 3, FormatStr   = varargin{3};  end
			if nargin >= 4, 
				for ind = 3 : 2 : length( varargin ) - 1,
					FormatStr.(lower(varargin{ind})) = varargin{ind+1};
				end
			end

			% This is the CallBack-function while zooming, panning or resizing
			if nargin == 1, 
				if strcmp( pos, 'callback' ),    
			        % from GetLinkedAxes() ...
			        tmp = getappdata( curr_ax );    % V 2.04
			        if isfield( tmp, 'graphics_linkaxes' ),
			        	Targets = get( tmp.graphics_linkaxes, 'Targets' );

			        	linked_axes = NaN( 1, length( Targets ) );
			        	for iTargets = 1 : length( Targets ),
			        		tmpChildren             = get( Targets( iTargets ), 'Children' );
			        		linked_axes( iTargets ) = get( tmpChildren(1), 'Parent' );
			        	end
			        else
			        	linked_axes = curr_ax;
			        end

			        for curr_ax = linked_axes,    % V 2.04
			        	UserData    = get( curr_ax, 'UserData' );
			        	if ~isfield( UserData, 'BorderTextHandles' ),   return;   end

			        	bt_handles  = UserData.BorderTextHandles;
			            if isfield( bt_handles, 'userdefined' ),    % V 2.08
			            	ax = axis;   dx = abs( ax(2) - ax(1) );   dy = abs( ax(4) - ax(3) );
			            	for ih = 1 : length( UserData.BorderTextHandles.userdefined ),
			            		htxt = UserData.BorderTextHandles.userdefined( ih );
			            		zmXY = UserData.BorderTextHandles.userdefined_textzoom( ih );
			            		if ishandle( htxt ) && zmXY,
			            			zmX = UserData.BorderTextHandles.userdefined_dx( ih ) / dx;
			            			zmY = UserData.BorderTextHandles.userdefined_dy( ih ) / dy;
			            			set( htxt, 'FontSize', min( zmX, zmY ) * abs( UserData.BorderTextHandles.userdefined_fsize( ih ) ) );
			            		end
			            	end
			            end
			            
			            AllFields = fieldnames( bt_handles );
			            for iflds = 1 : length( AllFields ),
			            	FieldName = AllFields( iflds ); FieldName = FieldName{1};
			            	th = UserData.BorderTextHandles.( FieldName );
			            	if ~ishandle( th ),   continue;   end

		            		if strncmpi( FieldName, 'inner', 5 ),
		            			FieldName = FieldName( 6 : end );
		            		end

		            		Xnew = NaN;   Ynew = NaN;   Znew = 0;
		            		switch FieldName,
			            		case 'topleft',     Xnew = ax(1+Xrev);          Ynew = ax(4-Yrev);
			            		case 'top',         Xnew = (ax(1)+ax(2))/2;     Ynew = ax(4-Yrev);
			            		case 'topright',    Xnew = ax(2-Xrev);          Ynew = ax(4-Yrev);
			            		case 'righttop',    Xnew = ax(2-Xrev);          Ynew = ax(4-Yrev);
			            		case 'right',       Xnew = ax(2-Xrev);          Ynew = (ax(3)+ax(4))/2;
			            		case 'rightbottom', Xnew = ax(2-Xrev);          Ynew = ax(3+Yrev);
			            		case 'bottomright', Xnew = ax(2-Xrev);          Ynew = ax(3+Yrev);
			            		case 'bottom',      Xnew = (ax(1)+ax(2))/2;     Ynew = ax(3+Yrev);
			            		case 'bottomleft',  Xnew = ax(1+Xrev);          Ynew = ax(3+Yrev);
			            		case 'leftbottom',  Xnew = ax(1+Xrev);          Ynew = ax(3+Yrev);
			            		case 'left',        Xnew = ax(1+Xrev);          Ynew = (ax(3)+ax(4))/2;
			            		case 'lefttop',     Xnew = ax(1+Xrev);          Ynew = ax(4-Yrev);
			            		case 'center',      Xnew = (ax(1)+ax(2))/2;     Ynew = (ax(3)+ax(4))/2;
			                    otherwise,          % skip
		                    end
		                    if ~isnan( Xnew ),   set( th, 'Position', [ Xnew Ynew Znew ] );   end
			            end
			        end
		        else
		        	fprintf('Usage: htext = ToolKit.BorderText( ''Position'', ''YourText'', ''[FormatString]'' );\n');
		        	fprintf('Usage: htext = ToolKit.BorderText( ''Position'', ''YourText'', FormatStruct );\n');
		        	fprintf('Usage: htext = ToolKit.BorderText( ''Position'', ''YourText'', ''Propery1'', Value1, ... );\n');
		        	error('Too few arguments.');
		        end

		        return;
			end

		    if nargin == 2,   FormatStr = [];   end

			% Make once in each figure an invisisible axes for text on 'figure'-level.
			UserData = get( fnr, 'UserData' );
			if ~isfield( UserData, 'BorderTextHandles' ) || ~ishandle( UserData.BorderTextHandles ),
				UserData.BorderTextHandles.h_axes = axes( 'Unit', 'Normalized', ...
					'Position', [0 0 1 1], 'Visible', 'off', 'Nextplot', 'add', 'Hittest','off');
				set( fnr, 'UserData', UserData, 'CurrentAxes', curr_ax );
			end
			h_axes = UserData.BorderTextHandles.h_axes;

			if ~ischar( pos ),
				UserPos = pos;   pos = 'userdefined';
			end

			%% Interpret/decode the FormatStruct / FormatString
			if ~isempty( FormatStr )  &&  ~isstruct( FormatStr ),
			    FormatString = FormatStr;   FormatStr = [];   % V 2.06
			    FormatString( FormatString == '[' ) = ' ';
			    FormatString( FormatString == ']' ) = ' ';
			    
			    SpacePos = find( FormatString == ' ' );
			    SpacePos = [ 0 SpacePos length(FormatString)+1 ];
			    
			    for i = 1 : length( SpacePos ) - 1,        
			    	cmd = FormatString( SpacePos(i)+1 : SpacePos(i+1)-1 ) ;
			    	cmd( isspace( cmd ) ) = '';
			    	if isempty( cmd ), 	 continue;   end

			    	switch cmd,            
			            case 'B',   FormatStr.FontWeight    = 'Bold';   % Bold
			            case 'I',   FormatStr.FontAngle     = 'Italic'; % Italic
			            case 'L',   FormatStr.Interpreter   = 'Latex';  % Latex interpreter
			            case 'T',   FormatStr.Interpreter   = 'Tex';    % Tex interpreter

			            case {'w','k','r','g','b','c','m','y'},         % FontColors
			            	FormatStr.Color = cmd;

			            case {'fw','fk','fr','fg','fb','fc','fm','fy'},	% FontColors
			            	FormatStr.Color = cmd(2);

			            case {'bw','bk','br','bg','bb','bc','bm','by'},	% BackgroundColors
			            	FormatStr.BackgroundColor = cmd(2);   

			            case {'ew','ek','er','eg','eb','ec','em','ey'}, % EdgeColors
			            	FormatStr.EdgeColor = cmd(2);     

			            case 'Hl',	FormatStr.HorizontalAlignment = 'left';       % Alignments
			            case 'Hc',  FormatStr.HorizontalAlignment = 'center';
			            case 'Hr',  FormatStr.HorizontalAlignment = 'right';

			            case 'Vb',  FormatStr.VerticalAlignment = 'bottom';
			            case 'Vm',  FormatStr.VerticalAlignment = 'middle';
			            case 'Vt',  FormatStr.VerticalAlignment = 'top';

			            case 'Z',   FormatStr.TextZoom          = 'on';  	% Zoomable Text

			            otherwise,
			                if cmd(1) == 'R',               % Rotation
			                	FormatStr.Rotation   = str2double( cmd( 2 : end ) );
			                	continue;
			                end
			                
			                tmp = abs( str2double( cmd ) ); % FontSize
			                if isnan( tmp ),
			                	fprintf('%s :: Unrecognized substring: ''%s''\n', ...
			                		mfilename, cmd );
			                else
			                	FormatStr.FontSize = tmp;
			                end
			        end
			    end
			end

			% Coordinates in HiddenAxis
			if strncmpi( pos, 'figure', 6 ),
				set( fnr, 'CurrentAxes', h_axes );
				xpos_left = 0.0;    xpos_middle = 0.5;    xpos_right  = 1.0;
				ypos_top  = 1.0;    ypos_middle = 0.5;    ypos_bottom = 0.0;
			end

			% Handle multi-line
			if ~iscell( txt ),
				ind = strfind( txt, '\n' );
				if isempty( ind ),
					txt = [ ' ' txt ' ' ];
				else
					str = [];
					ind = [ -1 ind length(txt)+1 ];
					for i = 2 : length( ind ),
			            str{i-1} = txt(ind(i-1)+2:ind(i)-1); %#ok<AGROW>
			        end
			        txt = str;   clear str;
			    end
			end

			% Translate 'pos' to [X Y]-coordinates
			switch lower( pos ),
				case 'topleft',
					h = text( ax(1+Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'top',
					h = text( (ax(1)+ax(2))/2, ax(4-Yrev), txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'topright',
					h = text( ax(2-Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'righttop',
					h = text( ax(2-Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 90 );

				case 'right',
					h = text( ax(2-Xrev), (ax(3)+ax(4))/2, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 90 );

				case 'rightbottom',
					h = text( ax(2-Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 90 );

				case 'bottomright',
					h = text( ax(2-Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 0 );

				case 'bottom',
					h	= text( (ax(1)+ax(2))/2, ax(3+Yrev), txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 0 );

				case 'bottomleft',
					h = text( ax(1+Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 0 );

				case 'leftbottom',
					h = text( ax(1+Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'left',
					h = text( ax(1+Xrev), (ax(3)+ax(4))/2, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'lefttop',
					h = text( ax(1+Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'center',
					h = text( (ax(1)+ax(2))/2, (ax(3)+ax(4))/2, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'middle', 'Rotation', 0 );

				case 'innertopleft',
					h = text( ax(1+Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 0 );

				case 'innertop',
					h = text( (ax(1)+ax(2))/2, ax(4-Yrev), txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 0 );

				case 'innertopright',
					h = text( ax(2-Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 0 );

				case 'innerrighttop',
					h = text( ax(2-Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'innerright',
					h = text( ax(2-Xrev), (ax(3)+ax(4))/2, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'innerrightbottom',
					h = text( ax(2-Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'innerbottomright',
					h = text( ax(2-Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'innerbottom',
					h = text( (ax(1)+ax(2))/2, ax(3+Yrev), txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'innerbottomleft',
					h = text( ax(1+Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'innerleftbottom',
					h = text( ax(1+Xrev), ax(3+Yrev), txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 90 );

				case 'innerleft',
					h = text( ax(1+Xrev), (ax(3)+ax(4))/2, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 90 );

				case 'innerlefttop',
					h = text( ax(1+Xrev), ax(4-Yrev), txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 90 );

				case 'figuretopleft',
					h = text( xpos_left, ypos_top, txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 0 );

				case 'figuretop',
					h = text( xpos_middle, ypos_top, ax(4), txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 0 );

				case 'figuretopright',
					h = text( xpos_right, ypos_top, txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 0 );

				case 'figurerighttop',
					h = text( xpos_right, ypos_top, [ txt ' ' ] );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'figureright',
					h = text( xpos_right, ypos_middle, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'figurerightbottom',
					h = text( xpos_right, ypos_bottom, txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 90 );

				case 'figurebottomright',
					h = text( xpos_right, ypos_bottom, txt );
					set( h, 'Horizontal', 'right', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'figurebottom',
					h = text( xpos_middle, ypos_bottom, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'figurebottomleft',
					h = text( xpos_left, ypos_bottom, txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'bottom', 'Rotation', 0 );

				case 'figureleftbottom',
					h = text( xpos_left, ypos_bottom, txt );
					set( h, 'Horizontal', 'left', 'Vertical', 'top', 'Rotation', 90 );

				case 'figureleft',
					h = text( xpos_left, ypos_middle, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'top', 'Rotation', 90 );

				case 'figurelefttop',
					h = text( xpos_left, ypos_top, [ txt ' ' ] );
					set( h, 'Horizontal', 'right', 'Vertical', 'top', 'Rotation', 90 );

				case 'figurecenter',
					h = text( xpos_middle, ypos_middle, txt );
					set( h, 'Horizontal', 'center', 'Vertical', 'middle', 'Rotation', 0 );

				case 'userdefined',
				        h = text( UserPos(1), UserPos(2), -1e99, txt, 'Clipping', 'on' );    % V 2.08
			        
			    otherwise,
			    	fprintf('%s :: Unrecognized ''Position'': ''%s''\n', mfilename, pos );
			    	clear h;
			    	return;
			end

			% Set Text-Properties
			if ~isfield( FormatStr, 'fontsize' ),
				if strncmpi( pos, 'figure', 6 ),    FormatStr.FontSize  = 12;
				else                                FormatStr.FontSize  =  8;
				end
			end

			if ~isfield( FormatStr, 'margin' ),     FormatStr.Margin    = eps;   end

			TextZoom = 'off';
			for fn = fieldnames( FormatStr )',
				fld = char(fn);
				if strcmp( fld, 'TextZoom' ),
					TextZoom = FormatStr.TextZoom;   continue;
				end
				set( h, fld, FormatStr.( fld ) );
			end

			set( fnr, 'CurrentAxes', curr_ax );     % Set scope to current axis

			% Store handles in the figure of in the subplot(axis)
			if strcmpi( pos, 'userdefined' ),
			    UserData = get( curr_ax, 'UserData' );    % V 2.05
			    if ~isfield( UserData, 'BorderTextHandles' ),   UserData.BorderTextHandles = struct();   end

		    	if ~isfield( UserData.BorderTextHandles, 'userdefined' ), iud = 1;
		    	else                                                      iud = length( UserData.BorderTextHandles.userdefined ) + 1;
		    	end
		    	UserData.BorderTextHandles.userdefined( iud )           = h;
		    	UserData.BorderTextHandles.userdefined_dx( iud )        = abs( ax(2) - ax(1) );
		    	UserData.BorderTextHandles.userdefined_dy( iud )        = abs( ax(4) - ax(3) );
		    	UserData.BorderTextHandles.userdefined_fsize( iud )     = FormatStr.FontSize;
		    	UserData.BorderTextHandles.userdefined_textzoom( iud )  = strcmpi( TextZoom, 'on' );
		    	set( curr_ax, 'UserData', UserData );
		    else
		    	if strncmpi( pos, 'figure', 6 ),    h_curr = fnr;
		    	else                                h_curr = curr_ax;
		    	end
		    	UserData = get( h_curr, 'UserData' );
		    	if isfield( UserData, 'BorderTextHandles' ),
		    		if isfield( UserData.BorderTextHandles, pos ),
		    			if ishandle( UserData.BorderTextHandles.(pos) ),
		    				delete( UserData.BorderTextHandles.(pos) );
		    			end
		    			UserData.BorderTextHandles = rmfield( UserData.BorderTextHandles, pos );
		    		end
		    	end
		    	UserData.BorderTextHandles.(pos) = h;
		    	set( h_curr, 'UserData', UserData );
		    end

			% Set Callback functions for zooming and panning
			set( zoom( fnr ), 'actionpostcallback',     'ToolKit.BorderText(''callback'')' );
			set( pan(  fnr ), 'actionpostcallback',     'ToolKit.BorderText(''callback'')' );
			set(       fnr,   'WindowButtonMotionFcn',  'ToolKit.BorderText(''callback'')' );
			set(       fnr,   'ResizeFcn',              'ToolKit.BorderText(''callback'')' );

			if nargout == 0;   clear h;   end

		end

		%% function Version = BorderText_GetVersion( fn )
		function Version = BorderText_GetVersion( fn )
			fid = fopen([ fn '.m' ], 'r' );
			if fid > 0,
				while true
					l = fgetl( fid );
		            if l == -1 % EOF
		            	break;
		            end

			    	index = strfind( l, 'function h = BorderText( varargin )' );
			    	if ~isempty( index )
			    		break;
			    	end
			    end
			    while true
			    	l = fgetl( fid );
			    	if l == -1 % EOF
			    		break;
			    	end
			    	if ~isempty(l)
				    	l( 1 : find( l~=' ' & l~='	', 1, 'first' ) - 1 ) = [];
				    end
		    		index = strfind( l, '% V' );
		    		if ~isempty( index )  &&  ( index(1) == 1 ),
		    			index = strfind( l, '-20' );
		    			if isempty( index ),  Version = l( 3 : end );
		    			else                Version = l( 3 : index(1)+4 );
                        end
                    end
                end
			    fclose( fid );
			else
			   	Version = 'Not found.';
			end
		end

		function fileNames = ListMatFiles( folder )
			%% Return the full path of all mat files in folder

			folder = ToolKit.RMEndSpaces(folder);
			if( folder(end) ~= '/' && folder(end) ~= '\' ), folder(end+1) = '\'; end
			fileNames = ls( folder );
			n = size(fileNames,1);
			index = zeros( 1, n );
			count = 0;
			for( i = 1 : n )
                fn = ToolKit.RMEndSpaces( fileNames(i,:) );
				if( strcmp( fn( max(1,end-3) : end ), '.mat' ) )
					index(count+1) = i;
					count = count+1;
				end
			end
			fileNames = fileNames( index(1:count), : );
			fileNames = [ repmat( folder, size(fileNames,1), 1 ), fileNames ];
		end

		function folderNames = ListFolders( folder )
			%% return the full path of all subfolders in folder

			folder = ToolKit.RMEndSpaces(folder);
			if( folder(end) ~= '/' && folder(end) ~= '\' ), folder(end+1) = '/'; end
			folderNames = ls( folder );
			n = size(folderNames,1);
			index = zeros( 1, n );
			count = 0;
			for( i = 3 : n )
				if( exist( [ folder, ToolKit.RMEndSpaces( folderNames(i,:) ) ], 'dir' ) == 7 )
					index(count+1) = i;
					count = count + 1;
				end
			end
			folderNames = folderNames( index(1:count), : );
			folderNames = [ repmat( folder, size(folderNames,1), 1 ), folderNames ];
		end

		function str = RMEndSpaces(str)
			%% remove the spaces at the end of a string
			if( ~isempty(str) ), str = str( 1 : find( str ~= ' ', 1, 'last' ) ); end
		end

		function data = Hist( rawData, edges, isDraw, isNorm )
			%% modified version of hist which counts and plots according to the edges exactly

			if( nargin() <= 2 || isempty(isDraw) )
				if( nargout() == 1 ) isDraw = false;
				else isDraw = true; end
            end
			if( nargin() <= 3 || isempty(isNorm) ) isNorm = false; end
			if( nargin() > 4 ), error( 'Usage: ToolKit.Hist( rawData, edges, isDraw=true )' ); end

			data = histc( rawData, edges );
			data(end) = [];
			if(isNorm) data = data / sum(data); end

			if( isDraw )
				bar( ( edges(1:end-1) + edges(2:end) ) / 2, data, 1 );
			end
		end

		function str = Array2Text( array )
			%% convert a 2D array into a string which could be printed on figures with text()

			str = [];
			for( i = 1 : size(array,1) )
				for( j = 1 : size(array,2) )
					str = [ str, sprintf( '%8.4f', array(i,j) ) ];
				end
				str = [ str, '\newline' ];
			end
		end

		function [ p, sign ]= PermutationTest( dataA, dataB, nPermutations )
			%% Test whether the mean of dataA is equal to the mean of dataB.
			%  		dataA:			a vector containing a set of sample data
			%		dataB:			a vector containing another set of sample data
			%		nPermutations:	number of permutations; if not given, it will be the number of all possible permutations
			%		p:				the p-value against the assumption that dataA and dataB were from the same distribution
			%		sign:			'<' ( mean(dataA) < mean(dataB) ) or '>' ( mean(dataA) > mean(dataB) )
			if( nargin() < 2 ), disp( 'Usage: ToolKit.PermutationTest( dataA, dataB, nPermutations )' ); end

			dataA = reshape( dataA, 1, [] );
			dataB = reshape( dataB, 1, [] );
			nA = size(dataA,2);
			nB = size(dataB,2);

			observed = mean(dataA) - mean(dataB);
			summation = sum(dataA) + sum(dataB);

			nShuffles = nchoosek( nA+nB, nA );
			if( nargin() == 3 && nPermutations > 0 && nPermutations < nShuffles )
				nShuffles = nPermutations;
				data = [dataA,dataB];
				rng('shuffle');
				for( i = nShuffles : -1 : 1 )
					shuffled(i,:) = data( randperm( nA+nB, nA ) );
				end
			else
				shuffled = combntns( [dataA,dataB], nA );
			end

			sumAs = sum( shuffled, 2 );
			sampled = sumAs / nA - ( summation - sumAs ) / nB;	% sampled mean difference data

			p = sum( sampled > observed ) / size(sampled,1);
			sign = '>';
			if( p > 0.5 )
				p = 1 - p;
				sign = '<';
			end
		end

		function ShowSignificance( loc1, loc2, pVal, hDist, isShowValues, varargin )
			%% ToolKit.ShowSignificance( point1, point2, pVal, hDist, isShowValues )
			%		loc1:	location of the top of the first data set
			%		loc2:	location of the top of the second data set
			%		pVal:	the p-value to show
			%		vDist:	vertical distance from the top of two data sets to show the p-value;
			%					it will be 10% of the height of the current axis if not given
			%		isShowValues:	true means showing the p-value exactly as it is; false means showing with stars. By default, it is false

			if( nargin() < 5 || isempty(isShowValues) ) isShowValues = false; end

			if( loc1(1) > loc2(1) )
				x1 = loc2(1);
				x2 = loc1(1);
			else
				x1 = loc1(1);
				x2 = loc2(1);
			end

			if( loc1(2) >= 0 || loc2(2) >=0 )
				y1 = max( [ loc1(2), loc2(2) ] );
				y2 = 1;
				vAlign = 'bottom';
			else
				y1 = min( [ loc1(2), loc2(2) ] );
				y2 = -1;
				vAlign = 'top';
			end

			hAxis = get( gca, 'ylim' );
			hAxis = hAxis(2) - hAxis(1);	% the height of current axis

			if( ~exist( 'hDist', 'var' ) || isempty(hDist) )
				hDist = hAxis * .05;
			else
				hDist = hAxis * hDist;
			end

			y1 = y1 + y2*hDist;
			y2 = y1 + y2 * hAxis * .02;

			plot( [ x1, x1, x2, x2 ], [ y1, y2, y2, y1 ], 'k' );
			
			if( isShowValues )
				txt = sprintf( '%.4f', pVal );
			else
				if(pVal < 0.001)
					txt = '***';
				elseif(pVal < 0.01)
					txt = '**';
				elseif(pVal < 0.05)
					txt = '*';
				else
					txt = 'ns';
			end
			text( double(x1+x2)/2, double(y2), txt, 'HorizontalAlignment', 'center', 'VerticalAlignment', vAlign, varargin{:} );

		end

		function ErrorFill( x, y, errors, varargin )
			%% fill a curve whose width represents +-error (e.g. std, sem)

			errors( isnan(errors) ) = 0;

			nany = [ 1 isnan(y), 1 ];
			index = nany(1:end-1) - nany(2:end);
			starts = find( index == 1 );
			ends = find( index == -1 ) - 1;

			for( i = [ starts; ends ] )
				fill( [ x( i(1) : i(2) ), x( i(2) : -1 : i(1) ) ], [ y( i(1) : i(2) ) - errors( i(1) : i(2) ), y( i(2) : -1 : i(1) ) + errors( i(2) : -1 : i(1) ) ], varargin{:} );
			end
		end

		function SurPeriods = PSMLatency( data, DPeriod, BLPeriod, SearchPeriod, Option, BinSize, pVal )
			%% SurPeriods = ToolKit.PSMLatency( data, DPeriod, BLPeriod, SearchPeriod, Option[, BinSize=2, pVal=0.05] );
			%
			%  output:
			%	SurPeriods				2-row array representing periods of "surprising" activities.
			%							The 1st row stores start time points while 2nd end time points (ms).
			%							If not given and the input argument "Option" is 'TrialByTrial', the distribution of surprising periods of all trials will be plotted
			%
			%  input:
			%	data					Cell array each element of which is a vector containing all spike time points (ms) of a single trial.
			%							Or a vector containing all spike time points (ms) of one single trial.
			%	DPeriod					2-element array describing the time period (ms) of the whole input data set, the 1st element for start and 2nd for end.
			%	BLPeriod				2-element array describing the time period (ms) of baseline activities, the 1st element for start and 2nd for end.
			%	SearchPeriod			2-element array describing the time period (ms) to search for "surprising" activities, the 1st element for start and 2nd for end.
			%	Option					
			%							'Population':	the method will be conducted on the average firing rate across all trials in a population manner.
			%							'TrialByTrial':	the method will 1st be conducted on each trial independently and the distribution of surprising periods of
			%											all trials will be returned, or plotted if output argument "SurPeriods" not given and "data" contains only one trial.
			%	BinSize					Size of time bin (ms) for average firing rate assessment; the value is 2ms by default.
			%	pVal					Threshold for the significance level, which makes statistics S = -log(pVal)), where pVal is the probability that the tested period fires
			%							not less than observed number of spikes at a Poisson distribution with the same average firing rate as the baseline activities.
			%							By default, pVal = 0.05 (S = 1.301).

			if( nargin() < 5 || isempty(Option) ) Option = 'TrialByTrial'; end
			if( nargin() < 6 || isempty(BinSize) ) BinSize = 2; end
			if( nargin() < 7 || isempty(pVal) ) pVal = 0.05; end	% 0.05 significance level
			if( nargin() < 4 || isempty(data) ) error( 'Usage: ToolKit.PSMLatency( data, DPeriod, BLPeriod, SearchPeriod[, Option, BinSize=2, pVal=0.05] )' ); end

			SurPeriods = [];

			% number of trials
			if( iscell(data) ) nTrials = length(data);
			elseif( ~strcmpi( class(data), 'double' ) || ~strcmpi( class(data), 'single' ) ||  length(data) ~= prod(size(data)) )
				error('Input argument "data" must be a cell array or a vector!');
				return;
			else
				nTrials = 1;
				data = {data};
			end

			% fix BLPeriod according to DPeriod if necessary
			if( BLPeriod(1) < DPeriod(1) )	BLPeriod(1) = DPeriod(1); end
			if( BLPeriod(2) > DPeriod(2) )	BLPeriod(2) = DPeriod(2); end
			if( SearchPeriod(1) < DPeriod(1) ) SearchPeriod(1) = DPeriod(1); end
			if( SearchPeriod(2) > DPeriod(2) ) SearchPeriod(2) = DPeriod(2); end

			% show figures
			figure;
			subplot(2,1,1); hold on;
			for( i = 1 : length(data) )
				x = zeros( 1, 3*size(data{i},2) );
				x(1:3:end) = data{i};
				x(2:3:end) = data{i};
				x(3:3:end) = NaN;
				y = zeros(size(x));
				y(1:3:end) = 4*i-3;
				y(2:3:end) = 4*i;
				y(3:3:end) = NaN;
				plot( x, y+50, 'k-', 'LineWidth', 1 );
			end
			set( gca, 'xlim', DPeriod, 'ylim', [1 4*i+100], 'ytick', [] );
			subplot(2,1,2); hold on;
			edges = DPeriod(1) : BinSize : DPeriod(2);
			xdata = histc( [data{:}], edges );
			xdata(end) = [];
			bar( ( edges(1:end-1) + edges(2:end) ) / 2, xdata, 1 );

			if( strcmpi( Option, 'trialbytrial' ) || nTrials == 1 )	% process in a trial by trial manner
				subplot(2,1,1); cla; hold on;
				for( iTrial = nTrials : -1 : 1 )
					data{iTrial} = sort( data{iTrial} );

					% get the average firing rate during baseline period in spikes/ms
					r = sum( BLPeriod(1) <= data{iTrial} & data{iTrial} < BLPeriod(2) ) / ( BLPeriod(2) - BLPeriod(1) );

					% detect bursts; for each burst, the 1st spike is counted in while the last spike is not
					data{iTrial}( data{iTrial} < SearchPeriod(1) | data{iTrial} > SearchPeriod(2) ) = [];
					iSpike = 1;
					SurPeriods{iTrial} = [];
					while( iSpike < length(data{iTrial}) - 2 )
						% whether average spacing of these three consecutive spikes longer than half of average inter-spike interval during baseline period
						dur = data{iTrial}(iSpike+2) - data{iTrial}(iSpike);
						if( dur > 1/r ) iSpike = iSpike + 1; continue; end

						% maximize the statistics S by adding following spikes and removing beginning spikes
						p = cdf( 'poiss', 2, r*dur );
						iEnd = iSpike + 2;
						for( k = iSpike+3 : length(data{iTrial}) )
							p_new = cdf( 'poiss', k-iSpike, r * ( data{iTrial}(k) - data{iTrial}(iSpike) ) );
							if( p_new > p ) p = p_new; iEnd = k;
							else break; end
						end
						iStart = iSpike;
						for( k = iSpike+1 : iEnd-1 )
							p_new = cdf( 'poiss', iEnd-k, r * ( data{iTrial}(k) - data{iTrial}(iEnd) ) );
							if( p_new > p ) p = p_new; iStart = k;
							else break; end
						end

						if( 1-p < pVal ) SurPeriods{iTrial} = [ SurPeriods{iTrial}, [iStart;iEnd] ]; end

						iSpike = iEnd + 1;
					end

					SurPeriods{iTrial} = reshape( data{iTrial}( SurPeriods{iTrial} ), 2, [] );

					plot( reshape( [SurPeriods{iTrial};NaN*ones(1,size(SurPeriods{iTrial},2))], 1, [] ), 50+iTrial*4*ones(3*size(SurPeriods{iTrial},2)), 'r-', 'LineWidth', 2 );
				end
			elseif( strcmpi( Option, 'population' ) )	% process in a population manner
				% concatenate all spike trains together
				data = [data{:}];

				% get average spike counts in a bin of size BinSize based on baseline activities
				% ATTENTION: no need to fit the baseline activities with a Poisson Distribution to get this average value,
				%            since the only parameter of a Poisson Distribution lambda is the mean value of the dataset.
				lambda = sum( BLPeriod(1) <= data & data < BLPeriod(2) ) / ( BLPeriod(2) - BLPeriod(1) ) * BinSize;

				% find the minimal number of spikes in a bin which makes a surprise
				i = 0;
				while(true)
					NThreshold = find( 1 - cdf( 'poiss', i+1 : i+50, lambda ) < pVal, 1, 'first' );
					if( isempty(NThreshold) )	i = i + 50;
					else
						NThreshold = NThreshold + i;
						break;
					end
				end

				% find surprising periods in the searching period
				SearchSpikeCounts = histc( data, SearchPeriod(1) : BinSize : SearchPeriod(2) );
				SearchSpikeCounts(end) = [];
				iBins = find( SearchSpikeCounts > NThreshold );
				if( isempty(iBins) ) return; end
				EndBins = find( iBins(2:end) - iBins(1:end-1) > 1 );
				if( isempty(EndBins) )	SurPeriods = [ iBins(1); iBins(end) ];
				else
					SurPeriods = iBins( [ 1, EndBins+1; EndBins, end ] );
				end

				% gaps shorter than 3 bins between surprising periods are mended, an the surprising periods shorter than 3 bins are removed.
				index = 1;
				for( i = 2 : size(SurPeriods,2) )
					if( SurPeriods(1,i) - SurPeriods(2,index) < 3 )
						SurPeriods(2,index) = SurPeriods(2,i);
					elseif( index+1 ~= i )
						SurPeriods(:,index+1) = SurPeriods(:,i);
						index = index + 1;
					end
				end
				SurPeriods( :, SurPeriods(2,:) - SurPeriods(1,:) < 3 ) = [];

				% convert bins into time points
				SurPeriods(1,:) = SearchPeriod(1) + BinSize * ( SurPeriods(1,:) - 1 );
				SurPeriods(2,:) = SearchPeriod(1) + BinSize * SurPeriods(2,:);
				
				h = plot( reshape( [SurPeriods;NaN*ones(1,size(SurPeriods,2))], 1, [] ), NThreshold*ones(3*size(SurPeriods,2)), 'r-', 'LineWidth', 2 );
				h(2) = plot( BLPeriod, [lambda lambda], 'g-', 'LineWidth', 2 );
				legend( h(1:2), 'Surprising periods with height of threshold', 'Average baseline activity' );
			end
		end


		function newData = ReSampling( data, originRate, newRate )
			newData = [];
			if( newRate < originRate )
				step = originRate / newRate;
				% nDots = fix( size(data,2) / step );
				% for( i = nDots : -1 : 1 )
				% 	newData(i) = mean( data( fix( (i-1)*step ) + 1 : fix(i*step) ) );
				% end
				nDots = round( size(data,2) / step );
				newData(nDots) = mean( data( round( (nDots-1)*step ) + 1 : end ) );
				for( i = 1 : nDots-1 )
					newData(i) = mean( data( round( (i-1)*step ) + 1 : round( i*step ) ) );
				end
			end
		end


		function iUnit = SpikeSorting( spikes,nUnits, isPlot )
			%% iUnit = SpikeSorting( spikes, nUnits, isPlot )
			%  input:
			% 	spikes				96 X N array containing spikes to sort, each column is one spike
			%	nUnits				number of units for the sorting
			%	isPlot				whether plot; by default, the value is false

			%  output:
			%	iUnit				unit number of each spike after sorting

			if( nargin() < 3 )
				isPlot = false;
			end


			iUnit = [];

			%% smoothing
			spkConvStep = 0.3;			
			spkConvKer = normpdf( -3:spkConvStep:3, 0, 1 ) / sum( normpdf( -3:spkConvStep:3, 0, 1 ) );
			kerLength = 3/spkConvStep*2+1;
			for( k = 1 : size(spikes,2) )
				tmp = spikes(:,k);
				spikes( (kerLength-1)/2+1 : 96-(kerLength-1)/2, k ) = conv( tmp, spkConvKer, 'valid' );

				% border process
				for( m = 1 : (kerLength-1)/2 )
					spikes(m,k) = sum( tmp( 1 : m+(kerLength-1)/2 )' .* spkConvKer( (kerLength-1)/2-m+2 : end ) ) / sum( spkConvKer( (kerLength-1)/2-m+2 : end ) );
					spikes(97-m,k) = sum( tmp( 97-m-(kerLength-1)/2 : end )' .* spkConvKer( 1 : (kerLength-1)/2+m ) ) / sum( spkConvKer( 1 : (kerLength-1)/2+m ) );
				end				
			end

			%% clustering
			[ ~, iMax ] = max(spikes(1:60,:));		% index of the highest point of each spike
			[ ~, iMin ] = min(spikes(1:60,:));		% index of the lowest point of each spike
			clusterData = zeros( 62, size(spikes,2) );
			for( iSpike = 1 : size(spikes,2) )
				lbs = [ iMin(iSpike), iMax(iSpike) ] - 20;	% lower bounds: lbs(1) for lower bound of valley; lbs(2) for lower bound of peak
				for( i = 1 : 2 )
					if( lbs(i) < 1 )
						if( mod( lbs(i), 2 ) )
							lbs(i) = 1;
						else
							lbs(i) = 2;
						end
					end
				end
				ubs = [ iMin(iSpike)+20, iMax(iSpike)+60 ]; % upper bounds: ubs(1) for upper bound of valley; ubs(2) for upper bound of peak
				for( i = 1 : 2 )
					if( ubs(i) > 96 )
						if( mod( ubs(i), 2 ) )
							ubs(i) = 95;
						else
							ubs(i) = 96;
						end
					end
				end
				clusterData( [ 11-(iMin(iSpike)-lbs(1))/2 : 11+(ubs(1)-iMin(iSpike))/2, 32-(iMax(iSpike)-lbs(2))/2 : 32+(ubs(2)-iMax(iSpike))/2 ], iSpike ) = spikes( [ lbs(1):2:ubs(1), lbs(2):2:ubs(2) ], iSpike );
			end

			iUnit = kmeans( clusterData', nUnits )';

			%% plot
			if( isPlot )
				PlotColors = 'wgycr';
				spikes( 97, : ) = NaN;
				set( figure, 'NumberTitle', 'off', 'name', 'Spikes' );
				hold on;
				set(gca,'color','k');
				plot( repmat( 1:97, 1, size(spikes,2) ), spikes(:), 'color', 'g' );

				
				tmpData = zeros(92,size(spikes,2));
				tmpData(92,:) = NaN;
				for( iSpike = 1 : size(spikes,2) )
					tmpData( max( [1 2-iMin(iSpike)+20] ) : min( [91 91-iMin(iSpike)-70+96] ), iSpike ) = spikes( max( [1 iMin(iSpike)-20 ] ) : min( [96 iMin(iSpike)+70] ), iSpike );

				end
				set( figure, 'NumberTitle', 'off', 'name', 'Clustering' );
				for( i = 1 : 5 )
					subplot(2,3,i);
					hold on;
					set(gca,'color','k','ylim',[-100 100]);
					tData = tmpData( :, iUnit==i );
					plot( repmat( 1:92, 1, size(tData,2) ), tData(:), 'color', PlotColors(i) );
					% for( j = 1 : size(tmpData,2) )
					% 	plot( 1:63, tmpData(:,j), PlotColors(i) );
					% 	% pause(0.01);
					% 	if( ~mod(j,100) )
					% 		% cla;
					% 	end
					% end
				end

			end
		end


		function patch = Gabor( waveLength, orientation, pahse, width, window, sigma )
			%% orientation:		counterclockwise; vertical gabor at 0; degrees
			%  pahse:			degrees
			%  width:			width of the patch in pixels
			%  window:			'gaussian' (gabor) or not (grating)
			%  sigma:			sigma of the Gaussian filter
			%  patch:			1st dimension: vertical(y); 2nd dimension: horizontal(x)
			if( nargin() < 5 )
				window = 'grating';
			elseif( nargin() < 6 )
				sigma = 1;
			end
			
			[ x, y ] = meshgrid( (1:width) - (1+width)/2.0, (1:width) - (1+width)/2.0 );
			X = x.*cosd(orientation) + y.*sind(orientation);
			Y = y.*cosd(orientation) - x.*sind(orientation);
			frequency = 1/waveLength;
			if( strcmp( lower(window), 'gaussian' ) )
				patch = cos( 2 * pi * frequency .* X + pahse/180*pi ) .* exp( -0.5 * (X.^2+Y.^2) / sigma^2 );
			else
				patch = cos( 2 * pi * frequency .* X + pahse/180*pi );
			end
			patch = patch / max(patch(:));
		end


		function img = Arcs( innerR, outerR, breakWidth, isPlot, isNewFigure )
			%% output:
			%	 img:				normalized to 1
			%  input:
			%    innerR:			radius of inner edge
			%    outerR:			radius of outer edge
			%    breakWidth:		angle of breaks between arcs (degrees)
			%    isPlot:			whether plot img; false by default
			%    isNewFigure:		whether plot on a new figure; true by default
			if( nargin() < 4 ) isPlot = false; end
			if( nargin() < 5 ) isNewFigure = true; end

			img = zeros( outerR*2+1, outerR*2+1 );
			angBound = [breakWidth/2, 90-breakWidth/2]' + (-2:1)*90
			for( x = -outerR : outerR )
				for( y = -outerR : outerR )
					ang = angle( y + i*x ) / pi * 180;
					if( any( angBound(1,:) <= ang & ang <= angBound(2,:) ) )
						img( x+outerR+1, y+outerR+1 ) = normpdf( norm( [x,y] ), (innerR+outerR)/2, (outerR - innerR)/4 );
					end
				end
			end
			img = img / max(img(:));

			if( isPlot )
				if(isNewFigure) figure; end
				imshow(img);
			end
		end
		

		function BulletComments( fname, bgColor )
			if( nargin() < 2 ) bgColor = 'w'; end

			bullets(3) = struct( 'Txt', 'text', 'Height', 0.5, 'FontSize', 24, 'Color', {'k'}, 'Delay', 0, 'Speed', 1, 'Location', 0 );
			
			bullets(1).Txt = 'How to do Decoding???';
			bullets(1).Height = 0.1;	% whole image height of 1
			bullets(1).FontSize = 20;
			bullets(1).Color = {'k'};
			bullets(1).Delay = 0;
			bullets(1).Speed = 0.07;	% imageWidth/s
			bullets(1).Location = 0;

			bullets(2).Txt = 'Oh, try a bunch of EEG voxels';
			bullets(2).Height = 0.3;	% whole image height of 1
			bullets(2).FontSize = 20;
			bullets(2).Color = {'g'};
			bullets(2).Delay = 0.3;
			bullets(2).Speed = 0.2;	% imageWidth/s
			bullets(2).Location = 0;

			bullets(3).Txt = 'Use a population of fMRI voxels!!!';
			bullets(3).Height = 0.5;	% whole image height of 1
			bullets(3).FontSize = 20;
			bullets(3).Color = {'c'};
			bullets(3).Delay = 0.5;
			bullets(3).Speed = 0.1;	% imageWidth/s
			bullets(3).Location = 0;

			bullets(4).Txt = 'Population of neurons of course!!!';
			bullets(4).Height = 0.7;	% whole image height of 1
			bullets(4).FontSize = 20;
			bullets(4).Color = {'b'};
			bullets(4).Delay = 0.7;
			bullets(4).Speed = 0.15;	% imageWidth/s
			bullets(4).Location = 0;

			bullets(5).Txt = 'Anyone knows the big boss behind? :(';
			bullets(5).Height = 0.9;	% whole image height of 1
			bullets(5).FontSize = 20;
			bullets(5).Color = {'r'};
			bullets(5).Delay = 0.75;
			bullets(5).Speed = 0.09;	% imageWidth/s
			bullets(5).Location = 0;

			set( figure, 'outerposition', [0 300 900 250], 'NumberTitle', 'off', 'name', fname, 'color', bgColor );
			axes( 'position', [0 0 1 1], 'XDir', 'reverse', 'YDir', 'reverse', 'visible', 'off' );

			T = max( [bullets.Delay] + 0.7 ./ [bullets.Speed] );
			frameRate = 12;
			for( iFrame = 1 : round( frameRate * T ) )
				cla;
				for( iBullet = 1 : size(bullets,2) )
					bullets(iBullet).Location = ( iFrame/frameRate - bullets(iBullet).Delay ) * bullets(iBullet).Speed;
					text( bullets(iBullet).Location, bullets(iBullet).Height, bullets(iBullet).Txt, 'color', bullets(iBullet).Color{1}, 'FontSize', bullets(iBullet).FontSize );
				end

				[img, map] = rgb2ind( frame2im( getframe(gcf) ), 20 );
				if( iFrame == 1 )
					imwrite( img, map, [fname, '.gif'], 'gif', 'LoopCount', inf, 'DelayTime', 1/frameRate );
				else
					imwrite( img, map, [fname, '.gif'], 'gif', 'WriteMode', 'append', 'DelayTime', 1/frameRate );
				end
			end

		end
	end

end