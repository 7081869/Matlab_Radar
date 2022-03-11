%%
fs = 1000; 
fc = 200;  
t = (0:1/fs:0.2)';
fm = t;

x = sin(2*pi*30*t);
fDev = 50;
x1 = smooth(x);
%%
clc;
clear;
close all;
t = 0:1/1e3:0.6;
y = chirp(t,0,1,80);
yneu = zeros(length(y) + 200);


t2 = 0.2:1/1e3:0.8;
y2 = chirp(t2,-20,1,80);
y2neu = zeros(length(y2) + 200);

for c = 1: length(y)
    yneu(c) = y(c);
    y2neu(200+c) = y2(c);
    
end


t3 = 0:1/1e3:0.8;
y3 = yneu(:,1) .* y2neu(:,1);

figure
set(gcf,'color','w'); % Set Background color white
plot(t3,yneu(:,1),'r', 'linewidth',2)
xlabel('Time (s)')
ylabel('Amplitude')

axis([0 0.8 -1. 1.])




figure
set(gcf,'color','w'); % Set Background color white
plot(t3,y2neu(:,1),'b', 'linewidth',2)
xlabel('Time (s)')
ylabel('Amplitude')

axis([0 0.8 -1. 1.])


figure
set(gcf,'color','w'); % Set Background color white
plot(t3,y3,'g', 'linewidth',2)
xlabel('Time (s)')
ylabel('Amplitude')

axis([0 0.8 -1. 1.])

%% 2 Geraden
clc;
clear;
t = 0:1/1e3:0.6;
t2 = 0:1/1e3:0.8;
y = t;
y2 = t2 - 0.2;
set(gcf,'color','w'); % Set Background color white
plot(t,y,'r',  'linewidth',2 )

axis([0 1 0 1.])
hold on
plot( t2, y2, 'b', 'linewidth',2 )
axis([0 1 0 1.])

set(gca,'XTick',[],'YTick',[])

hold off

%% Sinus
clc;
clear;
close all; %close all maybe opened windows
x = 0:1/1e3:10*pi;
y = sin(x);



set(gcf,'color','w'); % Set Background color white
plot(x,y,'g',  'linewidth',4 )
set(gca,'XTick',[],'YTick',[])
%set(gca,'XColor', "white" ,'YColor', "white" ,'TickDir','out')
%% FFT Zeichnung
%clear all; %clear all blank variables
 %close all; %close all maybe opened windows
 %clc;       %clean command window
 
 % DIGITAL SIGNAL PROCESSING - SINE WAVE
 
 Fs     = 50;                    %Sampling frequency : 150 Hz
 tvec  = 0:1/Fs:1;                %Time Domain vector of 1s
 
 f = 5;                           %Create frequency of 5Hz
 x = sin(2*pi*tvec*f);   
 nfft = 9024;                     %Length of FFT
 
 X = fft(x, nfft);
 %FFT is symmetric so throwing away 2nd half
 X = X(1:nfft/2);

 mx = abs(X);                      %Taking magnitude of fft of x
 f = (0:nfft/2-1)*Fs/nfft;

 %Plotting Signal [Time Domain]
 %figure
  
 %set(gcf,'color','w'); % Set Background color white
 %plot(tvec,X, 'g')
 %xlabel('Time / s')
 %ylabel('Amplitude / V')
%set(gca,'XTick',[],'YTick',[])
 
 %Plotting Chirp Signal [Frequency Domain]
 figure 
 set(gcf,'color','w'); % Set Background color white
 plot(f,mx, 'g','linewidth',4)
 set(gca,'XTick',[],'YTick',[])
 %xlabel('Frequency / Hz')
 %ylabel('Power / W')

