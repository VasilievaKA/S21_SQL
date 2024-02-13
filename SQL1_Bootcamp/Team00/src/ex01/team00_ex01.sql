WITH total_cost_table AS (
      WITH var AS (
            WITH tab AS (
            SELECT point1 AS points
            FROM nodes
            UNION
            SELECT point2 AS points
            FROM nodes
            GROUP BY points)
            SELECT t1.points AS point1,
                  t2.points AS point2,
                  t3.points AS point3,
                  t4.points AS point4,
                  t5.points AS point5
            FROM tab t1, tab t2, tab t3, tab t4, tab t5
            WHERE NOT t1.points = t2.points 
            AND NOT t1.points = t3.points
            AND NOT t1.points = t4.points
            AND NOT t2.points = t3.points
            AND NOT t2.points = t4.points
            AND NOT t3.points = t4.points
            AND t1.points = t5.points
            AND t1.points = 'A'
      ),
      tc AS (
      WITH tab AS (
      SELECT generate_series(1,(SELECT COUNT(nodes.id) FROM nodes), 1) AS i_id,
      generate_series(
      	(SELECT MAX(nodes.id) FROM nodes) + 1,
      	(SELECT COUNT(nodes.id) FROM nodes) + (SELECT MAX(nodes.id) FROM nodes),
      	1
      	) as id
      )
      SELECT *
      FROM nodes
      UNION
      SELECT tab.id,
            nodes.point2 AS pointt1,
            nodes.point1 AS pointt2,
            nodes.cost
      FROM tab INNER JOIN nodes ON tab.i_id = nodes.id 
      ORDER BY id
)
SELECT 
      (SELECT cost FROM tc WHERE var.point1 = tc.point1 AND var.point2 = tc.point2) +
      (SELECT cost FROM tc WHERE var.point2 = tc.point1 AND var.point3 = tc.point2) +
      (SELECT cost FROM tc WHERE var.point3 = tc.point1 AND var.point4 = tc.point2) +
      (SELECT cost FROM tc WHERE var.point4 = tc.point1 AND var.point1 = tc.point2) AS total_cost,
      CONCAT('{', point1, ',', point2, ',', point3, ',', point4, ',', point5, '}') AS tour
FROM var
)
SELECT *
FROM total_cost_table
WHERE total_cost_table.total_cost = (SELECT MIN(total_cost) FROM total_cost_table)
UNION
SELECT *
FROM total_cost_table
WHERE total_cost_table.total_cost = (SELECT MAX(total_cost) FROM total_cost_table)
ORDER BY total_cost, tour
;