/* Retrieve Application Link names and UUIDs From JIRA
 * Based on a query retrieved from the Atlassian troubleshooting docs:
 *
 *   https://confluence.atlassian.com/display/JIRAKB/How+to+remove+Application+link+directly+through+database
 *
 */
SELECT
  propertystring.propertyvalue AS "name",
  SUBSTR(propertyentry.property_key,16,36) AS "uuid"
FROM
  propertyentry, propertystring
WHERE
  propertyentry.id = propertystring.id AND
  propertyentry.property_key like 'applinks.admin%name';
