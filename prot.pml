
/* 01 */        #define N	4                           /* liczba procesow */
/* 02 */        bool chce[N], we[N], wy[N];
/* 03 */        #define i _pid

/* 04 */        active [N] proctype P()
/* 05 */        {

/* 06 */        start:
  
/* 07 */            chce[i] = true;

                    /* TODO: czekaj, az dla wszystkich k z [0..N-1] zachodzi !(chce[k] && we[k]) */

/* 08 */            we[i] = true;

                    /* TODO: jesli dla pewnego k z [0..N-1] zachodzi chce[k] && !we[k], to wykonaj 09..12, wpp. idź do 13 */
/* 09 */                {    
/* 10 */                    chce[i] = false;

                            /* TODO: czekaj, az dla pewnego k z [0..N-1] zachodzi wy[k] */
                      
/* 11 */                    chce[i] = true;
/* 12 */                }
    
/* 13 */            wy[i] = true;

                    /* TODO: czekaj, az dla wszystkich k z [i+1..N-1] zachodzi !we[k] || wy[k] */

                    /* TODO: czekaj, az dla wszystkich k z [0..i-1] zachodzi !we[k] */

  
                    /* SEKCJA KRYTYCZNA */


/* 14 */            wy[i] = false;
/* 15 */            we[i] = false;
/* 16 */            chce[i] = false;

/* 17 */            goto start
/* 18 */        }

