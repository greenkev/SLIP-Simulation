%PHASE Direct collocation phase object.
%
% Syntax:
%   obj = Phase(numberOfNodes);
%
% Required Input Arguments:
%   - numberOfNodes - (DOUBLE) Number of collocation nodes in phase.
%
% Description:
%   TODO

% Copyright 2013-2014 Mikhail S. Jones

classdef Phase < handle

  % PROTECTED PROPERTIES ==================================================
  properties (SetAccess = public)
    % Reference to parent direct collocation object
    nlp
    % Number of collocation nodes in phase
    numberOfNodes@double scalar
    % Phase duration variable
    duration@Variable scalar
    % Phase state variables
    state@Variable vector = Variable.empty
    % Phase input variables
    input@Variable vector = Variable.empty
    % Phase Lagrange multiplier variables
    lambda@Variable vector = Variable.empty
  end % properties

  % PUBLIC METHODS ========================================================
  methods
    function obj = Phase(nlp, numberOfNodes)
    %PHASE Direct collocation phase object constructor.
    % obj = PHASE(nlp, numberOfNodes)

      % Create reference to parent system object
      obj.nlp = nlp;

      % Set number of nodes in phase
      obj.numberOfNodes = numberOfNodes;

      % Add phase duration variable to parent problem
      expression = nlp.addVariable(1, 0, Inf, ...
        'Description', sprintf('Phase %d Duration', numel(nlp.phase)+1));

      % Create reference to duration in phase object
      obj.duration = expression;
    end % Phase

    function expression = addInput(obj, varargin)
    %ADDINPUT Add input to direct collocation phase object.

      % Add input variable to parent problem
      expression = obj.nlp.addVariable(varargin{:}, ...
				'Length', obj.numberOfNodes);

      % Create reference to input variable in phase object
      obj.input(end+1,1) = expression;
    end % addInput

    function expression = addState(obj, varargin)
    %ADDSTATE Add state to direct collocation phase object.

      % Add state variable to parent problem
      expression = obj.nlp.addVariable(varargin{:}, ...
				'Length', obj.numberOfNodes);

      % Create reference to state variable in phase object
      obj.state(end+1,1) = expression;
    end % addInput
  end % methods
end % classdef
