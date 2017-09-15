classdef Base
    %BASE Base class for all Auto* classes
    %   Copyright 2017 Andy Abate (abatea@oregonstate.edu)
    
    properties (Abstract, Constant, Hidden)
        domainRank % end subclasses set this, positive integer
    end
    
    methods
        function [props] = properties(o)
            props = builtin('properties',o);
        end
        function [o,props] = makeFieldsSymbolic(o)
            %MAKEFIELDSSYMBOLIC Takes an object and populates available fields with same-name symbols.
            %   Returns the modified object and cell array of replaced field names.
            props = o.properties(); % get names of available properties
            for i = 1:numel(props)  % loop through names
                p = props{i};
                o.(p) = sym(p,'real'); % set field to symbol
            end
        end
        function [q,qdot,qddot] = symbolicStateVariables(o,var)
            %SYMBOLICSTATEVARIABLES creates symbolic state variables
            %   var: character array variable name
            if ~exist('var','var'), var = 'q'; end
            n = o.domainRank;
            q = sym(var,[n,1],'real');
            qdot = sym([var 'dot'],[n,1],'real');
            qddot = sym([var 'ddot'],[n,1],'real');
        end
        function f = classfile(o)
            f = which(class(o));
        end
        function d = classfolder(o)
            d = fileparts(o.classfile);
        end
        function m = classmethod(o,methodname)
            m = fullfile(o.classfolder,strcat(methodname,'.m'));
        end
    end
    methods (Access = protected)
        function runBuildRule(o,methodnames,buildfunc)
            if ~iscell(methodnames), methodnames = {methodnames}; end
            destfiles = cellfun(@(s)o.classmethod(s),methodnames,'uniformoutput',false);
            sourcefiles = {o.classfile};
            if needsRebuild(sourcefiles,destfiles), buildfunc(); end
            %assert(needsRebuild(sourcefiles,destfiles) == false, 'Build rule did not produce required files')
        end
        function writeMethod(o,f,variables,parameters,methodname)
            filepath = o.classmethod(methodname);
            if ~iscell(variables), variables = {variables}; end
            if ~iscell(parameters), parameters = {parameters}; end
            
            % GENERATE INITIAL FUNCTION FILE
            matlabFunction(f,'vars',{variables{:},parameters{:}},'file',filepath); % cell array must be row
            % READ FROM FILE AND MODIFY
            s = fileread(filepath); % read all text from file
            idx = strfind(s,newline); idx = idx(1); % get end of first line
            header = s(1:idx); % get the whole first line (function definition)
            body = s(idx+1:end);
            % add obj as first argument to header
            header = char(insertAfter(header,'(','obj,'));
            % remove parameters from function header
            header = erase(header,strcat(',',parameters));
            % replace parameters in body
            body = regexprep(body,parameters,strcat('obj.',parameters));
            
            % REPLACE FILE WITH MODIFIED CODE
            fid = fopen(filepath,'w');
            if fid ~= -1
                clean = onCleanup(@() fclose(fid));
                fprintf(fid,'%s',[header,body]);
            end
        end
    end
    
end

function b = needsRebuild(sourcefiles,destfiles) % expects cells of char strings
youngestSource = 0;
oldestDestination = Inf;

for i = 1:numel(sourcefiles)
    d = dir(sourcefiles{i});
    if ~isempty(d), youngestSource = max(youngestSource,d.datenum); end
end
for i = 1:numel(destfiles)
    d = dir(destfiles{i});
    if ~isempty(d), oldestDestination = min(oldestDestination,d.datenum);
    else, oldestDestination = -1; end % destination is missing, always rebuild
end

% youngest source needs to be younger than oldest destination
% rebuild if it is not
b = ~(youngestSource < oldestDestination);

b = 1; %Temporary Hack, force rebuild every time
end
