resource "aws_wafv2_web_acl" "web_acl" {
  name        = "${var.project_prefix}-waf"
  description = "WAF for ALB - Rate limit and allow only Canada and North America"
  scope       = "REGIONAL"

  default_action {
    block {} # Block everything by default
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wafWebAcl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AllowCanadaNorthAmerica"
    priority = 0
    action {
      allow {}
    }
    statement {
      geo_match_statement {
        country_codes = [
          "CA", # Canada
          "US", # United States
        ]
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoAllowCanadaNA"
    }
  }

  rule {
    name     = "LimitRequestsPerIP"
    priority = 1
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 10
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = var.external_web_lb_arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}