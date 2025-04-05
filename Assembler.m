clear;clc;
%interface matlab with factory i/o using modbus TCP/IP
obj=modbus('tcpip','127.0.0.1',502);

% create sensors and actuators matrix

x=zeros(10,300);
y=zeros(8,300);
movez=0;
movex=0;

    for i=2:300
        
    % Read sensors signals    
    input0=read(obj,'inputs',1);
    input1=read(obj,'inputs',2);
    input2=read(obj,'inputs',3);
    input3=read(obj,'inputs',4);
    input4=read(obj,'inputs',5);
    input5=read(obj,'inputs',7);
    input6=read(obj,'inputs',8);
    input7=read(obj,'inputs',9);
    input8=read(obj,'inputs',10);
    input9=read(obj,'inputs',11);
    
    % Assigned senosors signal in x matrix
    %Moving X
    x(1,i)=input0;
    %Moving Z
    x(2,i)=input1;
    % Item detected
    x(3,i)=input2;
    % Lid at place
    x(4,i)=input3;
    % Lid clamped
    x(5,i)=input4;
    % Base at place
    x(6,i)=input5;
    % Base clamped
    x(7,i)=input6;
    % Pos. at limit (bases)
    x(8,i)=input7;
    % Part leaving
    x(9,i)=input8;
    % Start
    x(10,i)=input9;
    
        % if start is high
            % Sart Lids conveyor
            % Start Bases conveyor  
        if(x(10,i)==1)
           write(obj,'coils',4,1);
           write(obj,'coils',7,1);
        end
        
       % if bases at place changed to low 
           % stop bases conveyer 
           % start clamp base
        if(x(6,i-1)==1 && x(6,i)==0)
           write(obj,'coils',7,0);
           write(obj,'coils',8,1);
        end
        
       % if lid at place changed to low 
           % stop lid conveyer 
           % start clamp lid      
        if(x(4,i-1)==1 && x(4,i)==0)
           write(obj,'coils',4,0);
           write(obj,'coils',5,1);
        end
        
       % if lid clamped is high 
           % Start move Z    
        if(x(5,i)==1)
           write(obj,'coils',2,1);
           movez = 1;
        end 
        
        % if item detected is high 
            % start Grap
            % Stop clamp lid
         if(x(3,i)==1)
             write(obj,'coils',3,1);
             write(obj,'coils',5,0);
         end
         
         % if Moving Z and lid clamped are low  and movez =1
             % stop Move Z 
         if(x(2,i)==0 && x(5,i)==0 && movez==1 && y(3,i-2)==1)
              write(obj,'coils',2,0);
              movez=2;
         end  
         
         % if moving Z is change to low and movez=2
             % start move X
         if(x(2,i-1)==1 && x(2,i)==0 && movez==2)
              write(obj,'coils',1,1);
              movex=1;
         end
        
         % if moving X is change to low 
             % start move Z
         if(x(1,i-1)==1 && x(1,i)==0 && movex==1)
              write(obj,'coils',2,1);
              movez=3;
         end 
        
         % if moving Z is change to low 
             % stop grap
             % stop move Z
         if(x(2,i-1)==1 && x(2,i)==0 && movez==3)
              write(obj,'coils',3,0);
              write(obj,'coils',2,0);
              movez=4;
         end
         
         % if moving Z is change to low 
             % stop clamp base
             % start pos. raise (bases)
             % start base conveyor 
         if(x(2,i-1)==1 && x(2,i)==0 && movez==4)
            write(obj,'coils',8,0);
            write(obj,'coils',9,1);
            write(obj,'coils',7,1);
            movez=0;
         end 
         
         % if part leaving is change to low 
            % stop pos. raise 
            % stop move X
         if(x(9,i-1)==1 && x(9,i)==0)
            write(obj,'coils',9,0);
            write(obj,'coils',1,0);
            movex=0;
         end
        
    % Read actuator signals    
    coil0=read(obj,'coils',1);
    coil1=read(obj,'coils',2);
    coil2=read(obj,'coils',3);
    coil3=read(obj,'coils',4);
    coil4=read(obj,'coils',5);
    coil5=read(obj,'coils',7);
    coil6=read(obj,'coils',8);
    coil7=read(obj,'coils',9);
    
    % Assigned senosors signal in x matrix
    %Move X
    y(1,i)=coil0;
    %Move Z
    y(2,i)=coil1;
    % grap
    y(3,i)=coil2;
    % Lids conveyor
    y(4,i)=coil3;
    % clamp lid
    y(5,i)=coil4;
    % Base conveyor
    y(6,i)=coil5;
    % clamp base
    y(7,i)=coil6;
    % Pos. raise (bases)
    y(8,i)=coil7;

    end    