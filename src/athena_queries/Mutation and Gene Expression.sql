SELECT 
    s.location AS cancer_type,
    v.name AS mutation_name,
    AVG(s.gene_expression) AS avg_gene_expression
FROM 
    samples s
LEFT JOIN 
    vcf v 
ON 
    s.tumor = v.tumor
GROUP BY 
    s.location, v.name
ORDER BY 
    avg_gene_expression DESC;
