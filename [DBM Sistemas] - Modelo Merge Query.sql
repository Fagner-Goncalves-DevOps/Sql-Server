                            
INSERT 
	INTO 
		COBSYSTEMS_RELATORIOS.DBO.TAB_SKY_INTRA_IMP_DIA                            
														(                            
                         
															 COD_CRED ,                            
															 COD_DEV ,                            
															 COD_TIT ,                                                       
															 COD_PARC ,                                               
															 VCTO_PARC ,                            
														 )                            
SELECT 
	DISTINCT                                                       
	 T.COD_CRED,                              
	 T.COD_DEV,                              
	 T.COD_TIT,                                                          
	 CP.COD_PARC,                                                                       
FROM                              
	COBSYSTEMS_BASE5.DBO.TITULOS AS [T] WITH(NOLOCK)                                  
	CROSS APPLY
				(                                  
				  SELECT TOP 1                                  
						P.COD_PARC,                                                              
						P.VCTO_PARC,                                                            
					FROM                              
						COBSYSTEMS_BASE5.DBO.PARCELAS AS [P] WITH (NOLOCK)                                  
						JOIN COBSYSTEMS_BASE5.DBO.AUX_SKY AS [A] WITH(NOLOCK) ON A.COD_PARC = P.COD_PARC                                  
																						AND A.DATA_ENVIO BETWEEN @DATA_INI AND @DATA_FIM                              
						JOIN COBSYSTEMS_BASE5.DBO.IMPORTACAO_HISTORICO IH WITH(NOLOCK) ON IH.COD_TIT = P.COD_TIT                             
						JOIN COBSYSTEMS_BASE5.DBO.IMPORTACAO AS [IMP] WITH(NOLOCK)  ON IMP.COD_IMP = IH.COD_IMP                        
				  WHERE                              
						P.COD_TIT = T.COD_TIT                              
				  ORDER BY                              
						IH.COD_IMP DESC                              
				 ) AS [CP]                            
WHERE                            
	T.COD_CRED IN (10, 13, 44, 45)                            
 --AND T.COD_TIT = 16258122                              
                              

MERGE 
	COBSYSTEMS_RELATORIOS.DBO.TAB_SKY_INTRA_CART_ATIV AS [TSICA]             
USING 
	COBSYSTEMS_RELATORIOS.DBO.TAB_SKY_INTRA_IMP_DIA AS [TSIID] WITH(NOLOCK) ON TSICA.COD_TIT = TSIID.COD_TIT                            
																				AND TSICA.COD_CRED = TSIID.COD_CRED                            
																				AND TSICA.DATA_REF = TSIID.DATA_REF                
WHEN NOT MATCHED BY TARGET THEN                            
								INSERT                                  
									(                                  
										 DATA_REF ,                            
										 COD_CRED ,                            
										 COD_DEV ,                            
										 COD_TIT ,                                                      
										 COD_PARC ,               
										 VCTO_PARC ,                            
	                          
									)                                  
								VALUES                                  
									(                            
									 TSIID.DATA_REF ,                            
									 TSIID.COD_CRED ,                                  
									 TSIID.COD_DEV ,                                  
									 TSIID.COD_TIT ,                                                                 
									 TSIID.COD_PARC ,                                  
									 TSIID.VCTO_PARC ,                                  
                          
									);    