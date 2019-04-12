classdef MODiscretizer
% Apegandome al Codigo de Etica de los Estudiantes del Tecnologico de Monterrey, 
% me comprometo a que mi actuacion en este examen este regida por la honestidad academica.
    properties
        correlationMeasure;
        populationSize;
        maxEvaluations;
        MatrizDiscretizacion;
        NumeroDeBins;
        model;
    end
    
    properties (Hidden = true)
        studentName;
        studentID;
    end
    
    properties (SetAccess = protected, Hidden = true)
        %model;
        X;
        Y;
        classLabels;
        
    end
    
    methods
        function obj = MODiscretizer(X,Y,varargin)
            % Validating inputs
            if nargin < 2
                error('Missing arguments');
            end
            if size(X,1) ~= size(Y,1)
                error('Missmatch dimenssion: X and Y are not consistent');
            end
            % Defining defaults parameters
            obj.correlationMeasure = 'CAIM'; % {CAIM,Chi2,Phi}
            obj.populationSize = 100;
            obj.maxEvaluations = 1000;
            obj.studentName = 'Clemente Miguel Yáñez Contreras'; %% Fill with you information
            obj.studentID = 'A00817427'; %% Fill with you information
            
            
            
            % Updating arguments
            parametersList = fieldnames(obj);
            inputParametersLength = length(varargin);
            if inputParametersLength > 0
                if rem(inputParametersLength,2) == 0
                    for i = 1:2:inputParametersLength
                        parameterName = varargin{i};
                        parameterValue = varargin{i+1};
                        isParameter = strcmpi(parametersList,parameterName);
                        if any(isParameter)
                            obj.(parametersList{isParameter}) = parameterValue;
                        else
                            error(strcat(parameterName,' is not a parameter'));
                        end
                    end
                else
                    error('Missing arguments');
                end
            end
            if ~any(strcmpi(obj.correlationMeasure,{'caim','chi2','phi'}))
                error('Invalid correlation measure');
            end
            if ~all(strcmpi({class(obj.populationSize), ...
                    class(obj.maxEvaluations)},'double'))
                error('Invalid format');
            end
            obj.X = X;
            obj.Y = Y;
            obj.classLabels = unique(Y);
            NumeroDeBins = [];
            
        end 
    end
end
