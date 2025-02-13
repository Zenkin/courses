mw = 0.017;        //масса колес
Umax = 7.4         //управляющее напряжение (нужно только для моделирования)
mc = 0.595 - 4*mw;   //масса тележки
mp = 0.051;        //масса маятника
g = 9.82;          //ускорение свободного падения
L = 0.68;         //длина маятника
l =  L/2;          //расстояние до центра масс маятника
R = 7.54;          //сопротивление цепи якоря двигателя
r = 0.058/2;         //радиус колеса
km = 0.5;          //конструктивные постоянные
ke = 0.5;
J = 0.0023;        //приведенный момент инерции вала сервопривода
Jp = mp*L*L/12;          //момент инерции маятника (=J одн стержня отн. его центра масс) 
Jw = mw*r*r/2;  //момент инерции колес

tper = 1.0;     //Время перерегулирования

p=poly(0,"p");   //просто символ

//коэффициенты нужного характеристиского полинома (полином Ньютона)
p0 = 6.3/tper;
a_1 = p0^3;
a_2 = 3*p0^2;
a_3 = 3*p0;

//необходимые матрицы
E = {2*mp*L*r,  mp*L*L + 4*Jp;       
     mp*r*r + mc*r*r + 4*mw*r*r + 4*Jw + 2*J, 0.5*mp*L*r};

F = {0, 0;
     2*km*ke/R, 0};

G = {0, -2*mp*g*L;
     0, 0};

H = {0;  
     2*km/R};

EG = (E^-1)*G;
EF = (E^-1)*F; 
EH = (E^-1)*H;
EG = (-1)*EG;
EF = (-1)*EF;

A = {   0,       0,       1;          //матрица, определяющая динамические свойства ОУ
     EG(1,2), EF(1,1), EF(1,2);
     EG(2,2), EF(2,1), EF(2,2)};

B = {  0;                             //матрица входа управляющих воздействий
    EH(1,1); 
    EH(2,1)};
    

W = [B, A*B, A^2*B];                  //матрица управляемости

//проверка на управляемость 
if det(W) <> 0 then
    printf("\nIt can be controlled\n\n");
end
if det(W) == 0 then
    printf("\nIt can not be controlled\n\n");
end

C={1,0,0};          //матрица выхода

Q={  C;             //матрица наблюдаемости
    C*A;
   C*A^2};
   
//проверка на наблюдаемость 
if det(Q) <> 0 then
    printf("It is observable\n");
end
if det(Q) == 0 then
    printf("It is not observable\n");
end

a = coeff(det(p*eye(3,3) - A)); //коэффициенты характеристического полинома объекта управления

Ak =  {0,  1,  0;               //матрица, определяющая динамические свойства ОУ
       0,  0,  1;               //в канонической форме
      -a(1),-a(2),-a(3)}; 

Bk = {0;                        //матрица управляющих воздействий 
      0;                        //в канонической форме
      1};

Wk = {Bk, Ak*Bk, Ak^2*Bk];      //матрица управляемости в канонической форме

P = Wk*(W^-1);                  //матрица перехода

Kk = {a_1-a(1), a_2-a(2), a_3-a(3)};   //матрица коэффициентов обратной связи для Bk и Ak

K = Kk*P;                       //матрица коэффициентов обратной связи

printf("\nYou need: ");
disp(a_1+a_2*p+a_3*p^2+p^3);
printf("\nYou will have: ");
disp(det(p*eye(3,3)-(A-B*K)));
printf("\nWhere Koefs =:\n   k1 = %g  k2 = %g  k3 = %g\n\n", K(1), K(2), K(3));


//Для структурной схемы

//начальные условия
psi0 = 0;             //начальный угол маятника
dpsi0 = 0.2;          //начальная скорость падения маятника
dtheta0 = 0;          //начальная скорость колес

//Остальное
k1 = K(1);
k2 = K(2);
k3 = K(3);
i1 = A(2,2);
i2 = A(2,1);
i3 = B(2);
o1 = A(3,2);
o2 = A(3,1);
o3 = B(3);

////моделирование при рассчитанных коэффициентах:
//importXcosDiagram("C:\for_scilab\cart_on_3.zcos"); //полное имя файла со структурной схемой
//xcos_simulate(scs_m, 4);
////построение графиков с результатами
//subplot(2,2,1);
//xtitle("Угол (рад --- с)");
//plot2d(psi.time, psi.values,2);
//subplot(2,2,2);
//xtitle("Напряжение (В --- с)");
//plot2d(napr.time, napr.values,2);
//subplot(2,2,3);
//xtitle("Скорость падения (рад/с --- с)");
//plot2d(dpsi.time, dpsi.values,2);
//subplot(2,2,4);
//xtitle("Скорость колес (рад/с --- с)");
//plot2d(dtheta.time, dtheta.values,2);
//
//вывод найденных коэффициентов
printf("but in program you must put: \n");
disp(K*%pi/180)
