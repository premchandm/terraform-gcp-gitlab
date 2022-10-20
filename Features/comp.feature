Feature: Compliance Test tagging compliance

Scenario: Ensure compute enginer resources have tags
    Given I have google_compute_instance defined
    Then it must contain tags
    And its value must only be ssh,webserver

Scenario: Ensure all resources have tags
    Given I have resource that supports tags defined
    Then it must contain tags
    And its value must not be null