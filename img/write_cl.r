write.cl<-function(obj=NULL, header=T)
{
  write.table(obj, "clipboard", col.names=header, row.names=F, quote=F, sep="\t")
}