classdef Proyecto < PROBLEM
% <problem> <Proyecto>
% Apegandome al Codigo de Etica de los Estudiantes del Tecnologico de Monterrey, 
% me comprometo a que mi actuacion en este examen este regida por la honestidad academica.


    
    methods
        %% Initialization
        function obj = Proyecto()
            rng(1)
            obj.Global.M = 2; % Number of objectives
            obj.Global.lower    = zeros(1,obj.Global.D); % Lower bounds
            obj.Global.upper    = ones(1,obj.Global.D); % Upper bounds
            obj.Global.encoding = 'real'; % Sort of encoding
            
            
            
             
            
        end
        %% Calculate CalPob
        function PopCal = CalDec(obj,PopDec)
            % Sobrecarga de la funcion CalDec que crea una poblacion optima
            % dependiendo del numero del
           
            for i = 1 : obj.Global.N
            PopCal(i,:) = randi([0,1],obj.Global.CurrentColumn,1);
            end
            
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
          
           %Creacion de la matriz con los posibles puntos de corte y ademas
           %llenamos el arreglo PopObj con el numero de unos o el numero de
           %limites de discretizacion
           
            [N,D]  = size(PopDec);
            MatrizPuntosCorte = zeros(N,obj.Global.D);
            PopObj = zeros(N,obj.Global.M);
            %Count number of ones
            for j=1 : obj.Global.N
                Count = 0;
            for i = 1 : D
                if PopDec(j,i) == 1
                Count = Count +1;
                MatrizPuntosCorte(j,Count) = obj.Global.ArrElemDiff(1,i);
                end
            end
            if PopDec(j,D) == 0
                Count = Count + 1;
                MatrizPuntosCorte(j,Count) = obj.Global.ArrElemDiff(1,D);
            end
           
            PopObj(j,1) = Count;
            end
            
            
            %Esta parte genera una matriz de X discretizada en las columnas
            %atravez de los 100  individuos de la poblacion
            
            
            BinMatrix = zeros(N,size(obj.Global.ArrX,1)); 
            
            BinNum = 1; % Numero del Bin o intervalo al que pertenece
            Ind = 1; % Numero del individuo MatrizPuntosCorte
            Bin = 1; % Numero del iterador de las columnas de MatrizPuntosCorte
            iterArrX = 1;
            SumaCero = 0;
            SumaUno = 0;
            while(Ind<=100) %iteracion en la Poblacion
            iterArrX = 1;
            while(iterArrX <= size(obj.Global.ArrX,1) ) % itera en las instancias
             Bin = 1;
             
            while ( Bin <= PopObj(Ind,1)  ) %iterar entre los bins
                
                              %.ArrX(IndividuoXpoblacion,ElementodelArreglo)
                if (obj.Global.ArrX(iterArrX,1) <= MatrizPuntosCorte(Ind,Bin))
                BinMatrix(Ind,iterArrX) = Bin;
                Bin = D+1;
                else
                 Bin = Bin + 1;
                end
            end
            iterArrX =iterArrX +1;
            end
            Ind = Ind + 1;
            end
            
            %Esta parte genera una tabla de contingencia que nos va a
            %ayudar a obtener nuestros objetivos a maximizar
            
            TablaContingencia = zeros(3,D+1);
            for i = 1 : N % iterador atravez de los individuos
            TablaContingencia (:,:) = 0;
            
            for Inst = 1 : size(obj.Global.ArrX,1) %iterador atravez de cada instancia de ArrX
            if obj.Global.ArrY(Inst,1) == 0
                TablaContingencia(1,BinMatrix(i,Inst)) = TablaContingencia(1,BinMatrix(i,Inst))+ 1;
                TablaContingencia(1,PopObj(i,1)+1) = TablaContingencia(1,PopObj(i,1)+1) + 1;
                TablaContingencia(3,BinMatrix(i,Inst))= TablaContingencia(3,BinMatrix(i,Inst))+ 1;
            else
                TablaContingencia(2,BinMatrix(i,Inst)) = TablaContingencia(2,BinMatrix(i,Inst))+ 1;
                TablaContingencia(2,PopObj(i,1)+1) = TablaContingencia(2,PopObj(i,1)+1) + 1;
                TablaContingencia(3,BinMatrix(i,Inst))= TablaContingencia(3,BinMatrix(i,Inst))+ 1;
            end
            
            end
            TablaContingencia(3,PopObj(i,1)+1 )= TablaContingencia(1, PopObj(i,1)+1) + TablaContingencia(2,PopObj(i,1)+1 );
            
            % Determinacion de los objetivos
            
            
            
            m = TablaContingencia(3,PopObj(i,1)+1);
            if ( or(obj.Global.CorrelationMeasure == "Chi2", obj.Global.CorrelationMeasure == "Phi") )
            % X^2 = Sum[ (Nci - (Nc*Ni)/m)^2 / ((Nc*Ni)/m) ]
            Xcuad = 0;
            for Reng = 1: 2
            for z = 1: PopObj(i,1)
            
            Nci = TablaContingencia(Reng,z);
            Nc =TablaContingencia(Reng,PopObj(i,1)+1);
            Ni =TablaContingencia(3,z);
            
            %Primero determinamos el componente Chi2
            
            Xcuad = Xcuad +( (Nci - (Nc*Ni)/m)^2 / ((Nc*Ni)/m) );
             end
            end
            
            
            if ( obj.Global.CorrelationMeasure == "Chi2")
                PopObj(i,2) = -1*Xcuad;
                
            end
             %Y si lo necesitamos determinamos Phi
            
            if ( obj.Global.CorrelationMeasure == "Phi")
                
             phi = sqrt( Xcuad/m );
             PopObj(i,2) = -1*phi;
             % /phi^2 = X^2/n
             
            end % end of if Phi
            end %end of the if chi2 | Phi
            
            
            
          %Despues determinamos CAIM  si es necesario
            if ( obj.Global.CorrelationMeasure == "CAIM")
            Numerador = 0;
            
            for y = 1: PopObj(i,1)
                
                if TablaContingencia(1,y)< TablaContingencia(2,y)
                    Max2 = (TablaContingencia(2,y))^2;
                else
                    Max2 = (TablaContingencia(1,y))^2;
                end
            
                Numerador = Numerador +   Max2/TablaContingencia(3,y);
            end
            Caim = Numerador/m;
            
            PopObj(i,2) = -1*Caim;
            end %  end if caim
             
            
            end
            
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            
            P(:,1) = (0:1/(N-1):1)';
            P(:,2) = 1 - P(:,1).^2;
        end
    end
end