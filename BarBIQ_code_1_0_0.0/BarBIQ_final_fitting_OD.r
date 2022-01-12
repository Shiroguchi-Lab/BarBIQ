##BarBIQ_final_fitting_OD.r

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.12.02

###Before running, please change the following information which labeled by "CHECK1-4".

setwd("/yourpath") ### "CHECK1" path of your data
library (plotrix)

group1 <- read.table("output_filename_step15", ## "CHECK2" your data file name
    header=T, sep="")

outputname<- "EDrops.txt" ## "CHECK3" your output file name

write.table(t(c("ID", "EDrop", "SE")),file=outputname,sep="\t",col.names = F, row.names = F, quote = F)

## ID: the index ID;
## EDrop: operational droplet (OD);
## SE: standard error.

### For the sample SX
for (i in c("S1","S2")) ## "CHECK4" Indexes you want to analysis
    {
 sample<- i
 sampleA<-paste(c(sample,"A"),collapse = "_")
 sampleB<-paste(c(sample,"B"),collapse = "_")
 sampleO<-paste(c(sample,"O"),collapse = "_")
    group2 <- group1[(group1[,sampleA]>0 & group1[,sampleB]>0), ]
    x=log10(group2[,sampleA]*group2[,sampleB])
    y=group2[,sampleO]

data <- cbind(x,y)
data <- data.frame(data)
### Calculate the median
stock<-c()
for(i in seq(from=-0.4, to=10, by=0.2))
   {
     low=i;
     up=i+0.4;
     mid=low+0.2;
     data1<-data[data$x >low, ];
     data1<-data1[data1$x <= up, ];
    #  print(nrow(data1));
            if(nrow(data1)>2)
            {
             mean<-mean(data1[,2]);
             media<-median(data1[,2]);
             stock=rbind(stock,c(mid,mean,media));
            }
   }
stock <- data.frame(stock)
colnames(stock)=c("mid","mean","media")
stock$media<-log10(stock$media)
stock$mean<-log10(stock$mean)
stock[stock == "-Inf"]<- -2

select=stock[stock$media > -2, ];
x=select$mid
y=select$media

## Fitting
model <- lm(y ~ 1 + offset(x))
print(p<-summary(model))
predicted.intervals <- predict(model,data.frame(x=x),interval='confidence',
                                level=0.99)
      
# EDrop <-  read.table(outputname, header=F, sep="", colClasses=c("character"))
newdata<-t(c(sample, -model$coeff,p$coefficients[,2]))
# EDrop<-rbind(EDrop,newdata)
write.table(newdata,file=outputname,sep="\t",col.names = F, row.names = F, quote = F, append = T)
    
    }

##end##






