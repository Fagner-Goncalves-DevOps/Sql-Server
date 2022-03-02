
------------------------------------------------------------------------------------
/*
Create:Fagner Gonçalves 
Alterado por : --
*/
------------------------------------------------------------------------------------
USE [TELECOM]

GO

CREATE NONCLUSTERED INDEX IX_1 ON TAB_TELECOM_TELEFONES
    ( 
		DDD_TEL,NR_TEL ASC

	)

INCLUDE  (NOM_TIP,DES_STAT)
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE) --ON PRIMARY]

--WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON DW_VIVO_ACIONAMENTOS

