                                                   
CREATE VIEW [DBO].[VW_EVO_ACORDOS]                                                  
                   
                          
AS                                                            
            
                                    
SELECT           
  DISTINCT   --TOP 10              
	CONVERT(INT,5) AS [ID_SERVIDOR],                                                                 
	T.COD_TIT AS [IDCONTRATO],                                                                  
	3 AS IDEMPRESA, -- ??                                                                       
	TC.COD_TIT_CALC AS [IDACORDO],                                                                        
	TC.DATA_CAD AS [DATA_ACORDO] ,                                                                          
	RTRIM(T.CONTRATO_TIT) AS [CONTRATO] ,                                                                          
	DBO.F_EVO_PARCELAS(TC.COD_TIT_CALC) AS [TITULOS] ,                                                                                        
	CONVERT(NUMERIC(38,2),(TC.QTD_PARC * TC.VALOR_PARC) + TC.VR_ENTRADA) AS 'TOTAL_ACORDO',                                                                                            
	CONVERT(NUMERIC(9,5),TC.DESPERC_CALC) AS 'DESC_PRINCIPAL',                                                   
	(CASE                                               
	WHEN TC.COND_PARC = 'V' THEN TC.DATA_CALC ELSE TC.PRIM_VCTO END) AS 'DATA_ENTRADA',                                                            
	CASE                                               
	WHEN TC.VR_ENTRADA = 0 THEN TC.VALOR_PARC                                                   
	ELSE TC.VR_ENTRADA END AS 'VALOR_ENTRADA',                                                                  
	CASE                     
	WHEN TC.VR_ENTRADA > 0 THEN TC.QTD_PARC ELSE TC.QTD_PARC END AS 'QTDE_PARCELAS',                                                            
	CONVERT(NUMERIC(12,2),CASE                     
	WHEN TC.VR_ENTRADA = 0 AND TC.QTD_PARC = 1 THEN 0 ELSE TC.VALOR_PARC END) AS 'VALOR_PARCELA',                                                                     
	CONVERT(CHAR(14),RTRIM(D.CPFCGC_PES)) AS 'CPF_CNPJ',                                                                    
	CONVERT(VARCHAR(252),PE.RUA_ENDE) AS 'EMAIL',                      
	DX.TIPO AS 'CAMPANHA',    
	CASE                                                    
	WHEN OC.TITULO_OCOR LIKE '%AD-%'  THEN 'DIGITAL'    
	WHEN OC.TITULO_OCOR LIKE '%AD -%' THEN 'DIGITAL'  
	WHEN OC.TITULO_OCOR LIKE '%AD  -%'THEN 'DIGITAL'  
	ELSE 'HUMANO' END AS 'TIPO_TABULACAO',    
	DX.CARTEIRA,     
	I.DMQUE ,    
	D.COD_DEV,    
	OC.TITULO_OCOR,    
	HC.COD_OCOR    
FROM                                             
     COBSYSTEMS_BASE7.DBO.TITULOS [T] WITH(NOLOCK)                                           
     INNER JOIN COBSYSTEMS_BASE7.DBO.V_DEVEDORES [D] WITH(NOLOCK)ON D.COD_DEV = T.COD_DEV       
     CROSS APPLY                 
    (                
     SELECT TOP 1                 
      E.RUA_ENDE                
     FROM                
      COBSYSTEMS_BASE7.DBO.PESSOAS_ENDERECOS E WITH (NOLOCK)                
     WHERE                
      E.COD_PES = D.COD_PES                
      AND E.COD_TIPE = 6                 
      AND E.RUA_ENDE LIKE '%@%'                
      AND E.COD_STATE <> 3                
     ORDER BY                
      E.DATA_UP DESC                  
    ) PE                      
      CROSS APPLY                  
    (                  
    SELECT TOP 1                  
     TCC.COD_TIT_CALC,                                                               
     TCC.DATA_CAD,                  
     TCC.QTD_PARC,                  
     TCC.VALOR_PARC,                  
     TCC.VR_ENTRADA,                  
     TCC.DATA_CALC,                  
     TCC.COND_PARC,                  
     TCC.PRIM_VCTO,                  
     TCC.CAMPANHA_CALC,                  
     TCC.CANCELADO_CALC,            
     CP.DESPERC_CALC,                
     CP.COD_PARC                 
    FROM                   
     COBSYSTEMS_BASE7.DBO.TITULOS_CALCULO TCC WITH(NOLOCK)                   
     INNER JOIN COBSYSTEMS_BASE7.DBO.TITULOS_CALCULO_PARAM CP WITH(NOLOCK)ON CP.COD_TIT_CALC = TCC.COD_TIT_CALC         
    WHERE                  
     TCC.COD_TIT = T.COD_TIT                  
     AND TCC.CAMPANHA_CALC IS NOT NULL                
     AND TCC.CANCELADO_CALC = '0'                
     AND DATEDIFF(DD,TCC.DATA_CAD,GETDATE()) BETWEEN 0 AND  1                                 
     AND DATEDIFF(DD,GETDATE() ,(CASE WHEN TCC.COND_PARC = 'V' THEN TCC.DATA_CALC ELSE TCC.PRIM_VCTO END)) <= 10                  
    ORDER BY                  
     TCC.DATA_CAD DESC                  
    )TC                    
     INNER JOIN COBSYSTEMS_BASE7.DBO.PARCELAS PARCE WITH(NOLOCK)ON PARCE.COD_TIT = T.COD_TIT                 
														  AND PARCE.DEVOLVIDO_PARC = '0'                                                
														  AND PARCE.QUITADO_PARC = '0'                                                
														  AND PARCE.PARCELADO_PARC = '0'                 
														  AND PARCE.COD_PARC = TC.COD_PARC                   
  INNER JOIN COBSYSTEMS_BASE7.DBO.AUX_GVT I WITH(NOLOCK)  ON I.COD_PARC = [PARCE].COD_PARC         
  INNER JOIN COBSYSTEMS_BASE7.DBO.CARTEIRAS_FILAS_VIVO DX WITH(NOLOCK) ON DX.FILA = I.DMQUE    
  INNER JOIN COBSYSTEMS_BASE7.DBO.HISTORICOS_CLIENTES HC  WITH(NOLOCK) ON HC.COD_DEV = D.COD_DEV      
                            AND HC.COD_OCOR NOT IN (2974,107,103,8,2975,118,2551,7)    
  INNER JOIN COBSYSTEMS_BASE7.DBO.OCORRENCIAS_CLIENTES OC                  WITH(NOLOCK) ON OC.COD_OCOR = HC.COD_OCOR                                  
    
WHERE                                      
  T.COD_CRED IN (3)           
  AND CAST(HC.DATA_CAD AS DATE) = CAST(GETDATE() AS DATE)    
  --AND D.COD_DEV IN ( '45431702'  ,'6014942','42714956')    
GROUP BY                             
 T.COD_DEV                
 ,T.COD_TIT                                                              
 ,T.CONTRATO_TIT                                                                                                              
 ,TC.COD_TIT_CALC                                                              
,TC.VALOR_PARC                                           
,D.CPFCGC_PES                                                                 
,PE.RUA_ENDE                                                               
,TC.COND_PARC            
,TC.DATA_CALC            
,TC.PRIM_VCTO                                        
,TC.VR_ENTRADA                                                             
,TC.QTD_PARC                                                                                            
,TC.DATA_CAD                                            
,TC.DESPERC_CALC     
,DX.TIPO           
,I.DMQUE                 
,D.COD_DEV    
,DX.CARTEIRA    
,OC.TITULO_OCOR    
,HC.COD_OCOR    
,I.DMQUE     
,D.COD_DEV  
,OC.TITULO_OCOR  
,HC.COD_OCOR    


    
  