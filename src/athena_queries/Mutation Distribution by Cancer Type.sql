SELECT 
    s.location AS cancer_type,
    COUNT(v.name) AS mutation_count
FROM 
    samples s
LEFT JOIN 
    vcf v 
ON 
    s.tumor = v.tumor
GROUP BY 
    s.location
ORDER BY 
    mutation_count DESC;
