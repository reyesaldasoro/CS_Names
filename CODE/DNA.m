z=(0:0.4:10)';
n=26;
a=cos(z);
f=sin(z);
b=cos(z+pi);
g=sin(z+pi);
c=zeros(n,1);
d=[a c]';
e=[b c]';
h=[f c]';
i=[g c]';
hold
plot3(d,h,[z z],e,i,[z z],'linewidth',3)
text(c(1:2:n),c(1:2:n),z(1:2:n),'a t')
text(c(2:2:n),c(2:2:n),z(2:2:n),'c g')
plot3(a,f,z,b,g,z,'linewidth',10)
view(25,4)




%plot3(d(:,t1),h(:,t1),z2(:,t1),'-')
%plot3(e(:,t1),i(:,t1),z2(:,t1),'-')
%plot3(d(:,t2),h(:,t2),z2(:,t2),'-')
%plot3(e(:,t2),i(:,t2),z2(:,t2),'-*')
%plot3(a,f,z-0.3,'k-',b,g,z+-0.3,'b-','linewidth',5)
%plot3(a,f,z+0.3,'k-',b,g,z+0.3,'b-','linewidth',5)
