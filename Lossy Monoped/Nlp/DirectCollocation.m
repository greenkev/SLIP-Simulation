%DIRECTCOLLOCATION Defines a direct collocation optimization problem.
%
% Syntax:
%   obj = DirectCollocation();
%
% Description:
%   Helps set up a mode-scheduled optimization problem.

% Copyright 2013-2015 Mikhail S. Jones

classdef DirectCollocation < Nlp

  % PROTECTED PROPERTIES ==================================================
  properties (SetAccess = protected)
    % Vector of phase objects
    phase@Phase vector = Phase.empty
  end % properties

  % PUBLIC METHODS ========================================================
  methods
    function obj = DirectCollocation(varargin)
    %DIRECTCOLLOCATION Direct collocation NLP problem constructor.

      % Call superclass constructor
      obj = obj@Nlp(varargin{:});
    end % DirectCollocation

	function n = numberOfPhases(obj)
    %NUMBEROFPHASES Get method for number of phases.
      % Number of phases in problem
      n = numel(obj.phase);
    end % get.numberOfPhases
    
    function addPhase(o,numberOfNodes)
    %ADDPHASE
    % obj.ADDPHASE(numberOfNodes)
        o.phase(end+1) = Phase(o,numberOfNodes);
    end
    
    function [tStar,xStar,uStar] = getResponse(o)
        %GETRESPONSE Export direct collocation solution as response object.
        
        tStar = [];
        xStar = [];
        uStar = [];
        mStar = [];
        
        % Loop through phases
        for ip = 1:o.numberOfPhases
            % Number of nodes in current phase
            n = o.phase(ip).numberOfNodes;
            
            % Determine time interval
            if ip == 1
                tStar = linspace(0, eval(o.phase(ip).duration), n);
            else
                tStar = [tStar tStar(end)+linspace(0, eval(o.phase(ip).duration), n)];
            end % if
            % States
            xStar = [xStar reshape(eval(o.phase(ip).state), [], n)];
            % Inputs
            uStar = [uStar reshape(eval(o.phase(ip).input), [], n)];
            % Modes
            mStar = [mStar {sprintf('Phase %d', ip)}];
        end % for
    end % getResponse
  end % methods
end % classdef
