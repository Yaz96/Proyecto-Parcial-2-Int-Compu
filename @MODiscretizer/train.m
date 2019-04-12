function obj = train(obj)
% Apegandome al Codigo de Etica de los Estudiantes del Tecnologico de Monterrey, 
% me comprometo a que mi actuacion en este examen este regida por la honestidad academica.

% % disp(obj.X(1,1))
% % Here you code
NumColumnas = size(obj.X);
MatrizDiscr = zeros(NumColumnas);
NumRenglones = NumColumnas(1);
NumColumnas = NumColumnas(2);
ArregloMaxBins = zeros(1,NumColumnas);
obj.MatrizDiscretizacion = zeros(NumColumnas,80);
obj.NumeroDeBins= zeros(1,NumColumnas);

BinMax = 2;


%Creando un arreglo con cada uno de los valores de si si o no es un corte

columnas = size(obj.X,2);
for columna = 1 : columnas
    ArregloNumerosDif  = [];
    
   for i=1 : NumRenglones   %Determinando los valores diferentes en una columna y creando un arreglo de estos valores
    if not(ismember(obj.X(i,columna),ArregloNumerosDif) )
    ArregloNumerosDif(end+1) = obj.X(i,columna);
    end
end
ArregloNumerosDif=sort(ArregloNumerosDif);

%Se diferenció entre cuando el arreglo tiene 3 o más elementos diferentes para ahorrar tiempo en tener
%que hacer el algoritmo genetico solo para dos Bins

if (size(ArregloNumerosDif,2)>2)
    %Aqui se llama a Platemo columna por columna
main('-algorithm',@NSGAII,'-problem',@Proyecto,'-N',obj.populationSize,'-M',2,'-D',size(ArregloNumerosDif,2),'-evaluation',obj.maxEvaluations,'-run',1,'-save',1,'-CurrentColumn',size(ArregloNumerosDif,2),'-CorrelationMeasure',obj.correlationMeasure,'-ArrElemDiff',ArregloNumerosDif,'-ArrY',obj.Y,'-ArrX',obj.X(:,columna));
struct_name = load(fullfile('@MODiscretizer', 'NSGAII', 'Output.mat'));
Feasible     = find(all(struct_name.result{end}.cons<=0,2));
NonDominated = NDSort(struct_name.result{end}(Feasible).objs,1) == 1;
%Population contiene nuestro pareto front
Population   = struct_name.result{end}(Feasible(NonDominated));
%Si se quiere desplegar el pareto front se debe descomentar lo que esta
%abajo

%Metrics = {@IGD};
%figure('NumberTitle','off','UserData',struct(),...
%                           'Name',sprintf(['Runtime : %.2fs'],struct_name.obj.runtime));
%title(sprintf('%s on %s',func2str(struct_name.obj.algorithm),class(struct_name.obj.problem)),'Interpreter','none');
%Draw(Population.objs);


%Aqui se elige el indice de la knee del pareto front

indice =size(Population,2);

if (mod(indice,2)==1)
    indice = indice/2 +.5;
else
    indice = indice/2;
end
cambios = 1;

%A contianuacion se ordena el pareto front de menor numero de bins a mayor
while (cambios ~= 0)
    cambios = 0;
    tamano =size(Population,2);
for i =2 : tamano
    aux =Population(i).obj(1);
    if aux < Population(i-1).obj(1)
        popaux = Population(i-1);
        Population(i-1)=Population(i);
        Population(i) =popaux;
        cambios =cambios+1;
    end
end
end

%Y finalmente ganador es el individuo con el que nos quedamos
ganador= Population(indice);
arregloDiscretizador = [];

%Se crea un arreglo Con los numeros que son limites en sus rangos
for i = 1 : size(ganador.dec,2) 
    if ganador.dec(i) == 1
    arregloDiscretizador(end+1) = ArregloNumerosDif(i);
    end
end
arregloAux = arregloDiscretizador;

for i = size(arregloDiscretizador,2)+1 : 80
    arregloAux(i)=0;
    
end

%Se crea una matriz con los elementos discretizados

obj.MatrizDiscretizacion(columna,:) = arregloAux(1,:);
obj.NumeroDeBins(columna)= size(arregloDiscretizador,2);

for i = 1 : NumRenglones
    j = 1;
    while(j <= size(arregloDiscretizador,2) )
   if obj.X(i,columna) <= arregloDiscretizador(1,j)
       MatrizDiscr(i,columna) = j;
       if BinMax< j
           BinMax = j;
       end
       j = size(arregloDiscretizador,2)+1;
       
   else
       
       j = j +1;
       
   end  
   
   end
end

ArregloMaxBins(1,columna) = BinMax;


else
    
    %Se hace lo mismo pero con solo dos rangos de discretizacion
    if BinMax<2
    BinMax = 2
    end
    
    arregloDiscretizador = ArregloNumerosDif;
    obj.MatrizDiscretizacion(columna,1) = arregloDiscretizador(1,1);
    obj.MatrizDiscretizacion(columna,2) = arregloDiscretizador(1,2);
    obj.NumeroDeBins(columna)= 2;
    for i = 1 : NumRenglones
    j = 1;
    while(j <= size(arregloDiscretizador,2) )
   if obj.X(i,columna) == arregloDiscretizador(1,j)
       MatrizDiscr(i,columna) = j;
       j = size(arregloDiscretizador,2)+1;
   else
       j = j +1;
   end   
   end
end
    ArregloMaxBins(1,columna) = 2;
    
end


end 

% Comienza el entrenamiento

MatrizEntrenamiento = zeros( BinMax,columnas*2+2);

%Primero contamos el numero de 1 y el numero de 0 s que hay en la Y y al
%mismo tiempo sumamos uno a cada rango en el que este ese 0 o 1
Num1 = 0;
Num0 = 0;
for k = 1 : size(obj.X,1)
   if obj.Y(k,1) == 0
       Num0 = Num0 + 1;
       for col = 1:size(obj.X,2)
       MatrizEntrenamiento(MatrizDiscr(k,col) , (col-1)*2+2) =  MatrizEntrenamiento(MatrizDiscr(k,col), (col-1)*2+2 )+1;
       end
   else
       Num1 = Num1 + 1;
       for col = 1:size(obj.X,2)
       MatrizEntrenamiento(MatrizDiscr(k,col) , (col-1)*2+1) =  MatrizEntrenamiento(MatrizDiscr(k,col), (col-1)*2+1 )+1;
       end
   end

end
%Entonces se determina las probabilidades de cada uno de los elementos con
%la correccion de laplace para evitar ceros

MatrizEntrenamiento(1,end-1) = Num1/size(obj.X,1);
MatrizEntrenamiento(1,end) = Num0/size(obj.X,1);
for k = 1: columnas 
for reng = 1: ArregloMaxBins(1,k)
MatrizEntrenamiento(reng,(k-1)*2+1) = (MatrizEntrenamiento(reng,(k-1)*2+1)+1)/(Num1+ArregloMaxBins(1,k));
MatrizEntrenamiento(reng,(k-1)*2+2) =(MatrizEntrenamiento(reng,(k-1)*2+2)+1)/(Num0+ArregloMaxBins(1,k));
end    
end

%Terminamos guardando nuestro modelo
obj.model = MatrizEntrenamiento;



end