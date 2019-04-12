function [y,prob] = predict(obj,X)

% Apegandome al Codigo de Etica de los Estudiantes del Tecnologico de Monterrey, 
% me comprometo a que mi actuacion en este examen este regida por la honestidad academica.

if nargin < 2
    error('Missing arguments');
end

numSamples = size(X,1);
numClasses = length(obj.classLabels);
y = zeros(numSamples,1);
prob = zeros(numSamples,numClasses);



MatrizDiscretizada = zeros(numSamples , size(obj.X,2));

%Discretizamos las instancias a predecir
for inst = 1: numSamples     
for columns = 1 : size(X,2)
    j=1;
    while(j <= obj.NumeroDeBins(columns) )
        
       if X(inst,columns) <= obj.MatrizDiscretizacion(columns,j)
       MatrizDiscretizada(inst,columns) = j;
       j = obj.NumeroDeBins(columns)+1;
       else
       j = j +1;
   end  
    end

    end
end

% Likelihood en Yes
for pr = 1: numSamples
   Likelihoodyes = 1;
    for col = 1 : size(X,2)
    aux =obj.model(MatrizDiscretizada(pr,col), (col-1)*2+1);
    Likelihoodyes =Likelihoodyes * aux ;
    end
aux =obj.model(1, end-1);
Likelihoodyes =Likelihoodyes * aux ;


% Likelihood en No

   Likelihoodno = 1;
    for col = 1 : size(X,2)
    aux =obj.model(MatrizDiscretizada(pr,col), (col-1)*2+2);
    Likelihoodno =Likelihoodno * aux ;
    end
    
    aux =obj.model(1, end);
    Likelihoodno =Likelihoodno * aux ;
    
    %Finalmente determinamos las probabilidades y el resultado de cada
    %instancia
    
    Probabilidadyes = Likelihoodyes/(Likelihoodyes+Likelihoodno);
    Probabilidadno = Likelihoodno/(Likelihoodyes+Likelihoodno);
    prob(pr,1) = Probabilidadyes;
    prob(pr,2) = Probabilidadno;
    if Probabilidadyes > Probabilidadno
    y(pr,1) = 1;
    else
    y(pr,1) = 0;
    end

end




end