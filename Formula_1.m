```matlab
% Este código calcula varios parámetros y realiza una representación gráfica.

% Solicita al usuario que ingrese la velocidad de la curva.
disp("De 9.3991-15.7101 m/s o mayor se derrapa el carro")
v=input('Ingresa Velocidad de curva: ');

% Define los puntos de referencia para ajustar una función cúbica.
x1=10;y1=290;
x2=280;y2=120;
x3=90;y3=75;
x4=213;y4=250;

% Almacena los valores de y en un vector y los valores de x en una matriz.
valoresy=[y1; y2; y3; y4];
valoresx=[x1.^3,  x1.^2, x1, 1;
          x2.^3,  x2.^2, x2, 1;
          x3.^3,  x3.^2, x3, 1;
          x4.^3,  x4.^2, x4, 1];

% Calcula los coeficientes para una función cúbica.
abcd=valoresx\valoresy;

% Crea un vector de valores x para la representación gráfica.
vx=linspace(1,300,300);

% Calcula los valores de y utilizando la función cúbica.
vy=abcd(1)*vx.^3 + abcd(2)*vx.^2 + abcd(3)*vx + abcd(4);

% Define la función avy para los cálculos posteriores.
avy=@(x) abcd(1)*x.^3 + abcd(2)*x.^2 + abcd(3)*x + abcd(4);

% Crea una figura para la representación gráfica.
figure('Name', 'Gráfica de la función', 'NumberTitle', 'off');

% Establece límites en el eje de la gráfica.
hold on
axis([0,350,0,350])

% Representa la función en la gráfica.
plot(vx,avy(vx),'Color',[0.7 0.7 0.7],'LineWidth',10)
textoVelocidad="Velocidad en Curva: "+num2str(v);
text(75,275,textoVelocidad)

% Calcula las derivadas de la función para su uso posterior.
dvy=@(x) 3*abcd(1)*x.^2 + 2*abcd(2)*x + abcd(3);
ddvy=@(x) 6*abcd(1)*x+2*abcd(2);

% Calcula el radio de curvatura en función de x.
radioCurva=@(x)((1+dvy(x).^2).^(3/2))./abs(ddvy(x));

% Calcula la longitud de la curva.
longCurva=integral(dvy,300,0);
strLong="Longitud de Curva: "+num2str(longCurva);
text(75,325,strLong,"FontSize",15,"FontName","times")

% Encuentra los puntos de máximo y mínimo en la gráfica de la función.
minFun=find(avy(vx)==min(vy(50:125)));
maxFun=find(avy(vx)==max(vy(200:250)));

% Calcula el radio de curvatura en esos puntos.
radio1=radioCurva(minFun);
radio2=radioCurva(maxFun);

% Muestra el radio de curvatura en la gráfica.
strRad1=num2str(radio1);
text(70,130,strRad1);
strRad2=num2str(radio2);
text(200,200,strRad2);

% Inicializa los vectores vxradio1 y vxradio2 antes del bucle for.
vxradio1 = zeros(size(vx));
vxradio2 = zeros(size(vx));

% Rellena los vectores vxradio1 y vxradio2 con los valores de x que cumplen la condición.
for i=vx
    radio=radioCurva(i);
    if radio<50
        if i<150
            vxradio1(i) = i;
        else
            vxradio2(i) = i;
        end
    end
end

% Elimina los ceros de los vectores vxradio1 y vxradio2.
vxradio1(vxradio1 == 0) = [];
vxradio2(vxradio2 == 0) = [];

% Representa las zonas de derrape en la gráfica.
plot(vxradio1,avy(vxradio1),"Color",'yellow','LineWidth',9);
plot(vxradio2,avy(vxradio2),"Color",'yellow','LineWidth',9);

% Define las funciones para las rectas tangentes y perpendiculares.
vxTang=@(x) x:x+50;
vxPend=@(x) x-50:x;

rectaTang=@(x) avy(x)+dvy(x)*(vxTang(x)-x);
rectaPend=@(x) avy(x)+(-1./dvy(x))*(vxPend(x)-x);

% Crea figuras que representan las rectas tangentes y perpendiculares.
shape1=nsidedpoly(100,'Center',[min(vxradio1),vy(min(vxradio1))],'Radius',20);
grada1=polyshape([52,52+80,52+80,52],[70,70,70-10,70-10]);
plot(rotate(grada1,-48,[52,70]))

shape2=nsidedpoly(100,'Center',[min(vxradio2),vy(min(vxradio2))],'Radius',20);
grada2=polyshape([193,193+80,193+80,193],[261,261,261+10,261+10]);
plot(rotate(grada2,39,[193,261]))

% Define algunas constantes y calcula las velocidades máximas.
g=9.8;
friccCinetica=0.6;
friccEstatica=0.8;

vxvelmax1=radioCurva(vxradio1);
vxvelmax2=radioCurva(vxradio2);

for i=1:length(vxvelmax1)
    vmax=sqrt(g*friccEstatica*vxvelmax1(i));
    vxvelmax1(i)=vmax;
end

for i=1:length(vxvelmax2)
    vmax=sqrt(g*friccEstatica*vxvelmax2(i));
    vxvelmax2(i)=vmax;
end

% Calcula la energía perdida y la distancia máxima recorrida.
masa=750;
energiaPerdida=@(v) 0.5*masa*v^2;
distanciaRecorrida=@(v) v^2/(2*friccCinetica*g);

% Crea una línea animada para representar el recorrido del carro.
carro=animatedline;
clearpoints(carro);
breakk=0;
indexcurva=1;

% Recorre los valores de x para el carro.
for posx=vx
    indexcurva=posx-(min(vxradio1))+1;
    if ismember(posx,vxradio1)==1 && v>vxvelmax1(indexcurva)
        breakk=1; break
    else
        addpoints(carro,vx(posx),vy(posx))
        drawnow
    end
end

% Si se alcanza el derrape, realiza la representación de la zona de derrape.
if breakk==1
    for i=1:length(vxradio1)
        vxTangDerrape=vxTang(posx);
        vyTangDerrape=rectaTang(posx);
        addpoints(carro,vxTangDerrape(i),vyTangDerrape(i));
        drawnow
    end
    energiaTexto="Calor: "+num2str(energiaPerdida(v))+"J";
    distanciaTexto="dMax: "+num2str(distanciaRecorrida(v))+"m";
    text(75,250,energiaTexto);
    text(75,225,distanciaTexto);
end

% Añade títulos y etiquetas a tus gráficas.
title('Gráfica de la función')
xlabel('Eje X')
ylabel('Eje Y')
```
