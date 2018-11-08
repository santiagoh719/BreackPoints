Buishand_R <- function(serie,n_period=10,dstr='norm',simulations = 1000){

  serie <- as.vector(serie)
  n <- length(serie)
  na_ind <- is.na(serie)
  n_no_na <- n - sum(as.numeric(na_ind))
  if(n < 2*n_period){
    stop('serie no long enough or n_period to long')
  }
  serie_mean <- mean(serie,na.rm = T)
  serie_sd <- sd(serie,na.rm = T)
  if(dstr == 'gamma'){
    delta <- min(serie[!na_ind]) - 1
    par_gamma <- fitdistr(serie[!na_ind]-delta,'gamma')
  }
  serie_com <- serie[!na_ind]


  i_ini <- n_period
  i_fin <- n-n_period

  serie <- serie-serie_mean

  a_v1 <- 0
  a_v2 <- max(serie, na.rm = T)
  for(i in i_ini:i_fin){
    a <-sum(serie[1:i],na.rm = T)/serie_sd
    if( a > a_v1){
      a_v1 <- a
      i_break1 <- i
    }
    if(a < a_v2){
      a_v2 <- a
      i_break2 <- i
    }
  }
  a_v <- (a_v1 - a_v2)/sqrt(n_no_na)
  if(abs(a_v2) >abs(a_v1)){ i_break <- i_break2
  }else{i_break <- i_break1}

  a_sim <- vector(mode = 'double',length = simulations)
  if(dstr == 'norm'){
    for(i in 1:simulations){

      aux <- rnorm(n_no_na,mean=serie_mean,sd = serie_sd)

      sd_aux <- sd(aux)
      mn_aux <- mean(aux)
      aux <- aux - mn_aux

      a_v1 <- 0
      a_v2 <- max(aux)+1
      for(j in i_ini:(n_no_na-n_period-1)){
        a <-sum(aux[1:j],na.rm = T)/sd_aux
        if( a > a_v1){
          a_v1 <- a
        }else if(a < a_v2){
          a_v2 <- a
        }
      }
      a_sim[i] <- (a_v1 - a_v2)/sqrt(n_no_na)
    }
  } else if( dstr == 'gamma'){
    for(i in 1:simulations){

      aux <- rgamma(n=n_no_na,shape=par_gamma$estimate[1],rate = par_gamma$estimate[2])
      aux <- aux + delta
      sd_aux <- sd(aux)
      mn_aux <- mean(aux)
      aux <- aux - mn_aux

      a_v1 <- 0
      a_v2 <- max(aux)+1
      for(j in i_ini:(n_no_na-n_period-1)){
        a <-sum(aux[1:j],na.rm = T)/sd_aux
        if( a > a_v1){
          a_v1 <- a
        }else if(a < a_v2){
          a_v2 <- a
        }
      }
      a_sim[i] <- (a_v1 - a_v2)/sqrt(n_no_na)
    }

  } else if (dstr == 'self'){
    for(i in 1:simulations){

      aux <- sample(x = serie_com,replace = T,size = n_no_na)

      sd_aux <- sd(aux)
      mn_aux <- mean(aux)
      aux <- aux - mn_aux

      a_v1 <- 0
      a_v2 <- max(aux)+1
      for(j in i_ini:(n_no_na-n_period-1)){
        a <-sum(aux[1:j],na.rm = T)/sd_aux
        if( a > a_v1){
          a_v1 <- a
        }else if(a < a_v2){
          a_v2 <- a
        }
      }
      a_sim[i] <- (a_v1 - a_v2)/sqrt(n_no_na)
    }

  }else{
    stop('not support dstr')
  }
  cum_dist_func <- ecdf(a_sim)
  p <- 1-cum_dist_func(a_v)
  out <- list(breaks = i_break+1 ,p.value = p)
  return(out)
}