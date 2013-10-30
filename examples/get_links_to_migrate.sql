/* Huge, hairy SELECT statement that copies link data to CSV */
COPY (
WITH

  /* This defines the group of projects which are migrating to a new JIRA
   * instance
   */
  migrated_projects AS (
    VALUES
      ('FACT'),
      ('PP'),
      ('HI'),
      ('OS'),
      ('MCO'),
      ('PDB'),
      ('GTO'),
      ('RAZOR')
  ),

  /* JIRA 6.1 replaced the pkey column which held the issue key, "PP-22", with
   * the issuenum column which just holds the issue number: "22". This view
   * re-constitutes the issue keys, plus saves the project identifier, "PP", so
   * that it can be later checked against the list defined above.
   */
  munged_issues AS (
    SELECT
      jiraissue.id,
      project.pkey || '-' || jiraissue.issuenum AS "key",
      project.pkey
    FROM
      jiraissue,
      project
    WHERE
      jiraissue.project = project.id
  ),

  /* This selects all links that originate OR terminate in the group of
   * migrated projects but do not originate AND terminate in the group of
   * migrated projects.
   */
  munged_links AS (
    SELECT
      issuelink.*
    FROM
      issuelink
    JOIN
      munged_issues AS source_issue
      ON issuelink.source = source_issue.id
    JOIN
      munged_issues AS dest_issue
      ON issuelink.destination = dest_issue.id
    WHERE
      (
        source_issue.pkey IN (SELECT * FROM migrated_projects) AND
        dest_issue.pkey NOT IN (SELECT * FROM migrated_projects)
      ) OR
      (
        source_issue.pkey NOT IN (SELECT * FROM migrated_projects) AND
        dest_issue.pkey IN (SELECT * FROM migrated_projects)
      )
  )

/* This selection gathers link data targetted by the munged_links query and
 * exports it to CSV in the format expected by the jira-remotelinker tool.
 */
SELECT
  CASE
    WHEN source_issue.pkey IN (SELECT * FROM migrated_projects) THEN 'public'
    ELSE 'private' END
  AS "source_instance",
  source AS "source_id",
  source_issue.key AS "source_key",
  outward AS "source_relation",
  CASE
    WHEN dest_issue.pkey NOT IN (SELECT * FROM migrated_projects) THEN 'private'
    ELSE 'public' END
  AS "target_instance",
  destination AS "target_id",
  dest_issue.key AS "target_key",
  inward AS "target_relation"
FROM munged_links AS issuelink
JOIN
  issuelinktype AS type
  ON issuelink.linktype = type.id
JOIN
  munged_issues AS source_issue
  ON issuelink.source = source_issue.id
JOIN
  munged_issues AS dest_issue
  ON issuelink.destination = dest_issue.id )
TO '/tmp/links_to_migrate.csv' WITH CSV HEADER;
