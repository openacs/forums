
--
-- The Forums Package - Alerts
--
-- @author gwong@orchardlabs.com,ben@openforce.biz
-- @creation-date 2002-05-16
--
-- This code is newly concocted by Ben, but with significant concepts and code
-- lifted from Gilbert. Thanks Orchard Labs!
--

--
-- the problem in the original bboard code was the scoping of the alerts
-- technically, alerts are scoped given which forum they refer to.
-- That's great if everyone follows the convention of checking alerts
-- with a subquery on forums. I'm toying with the idea of directly scoping
-- the alerts. It's a denormalization that is cheap and probably will
-- lead to better developer behavior.
--
-- Ben
--

create table forums_alerts (
       alert_id                 integer not null
                                constraint forums_forum
