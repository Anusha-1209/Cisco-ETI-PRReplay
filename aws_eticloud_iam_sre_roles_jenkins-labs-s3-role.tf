data "aws_iam_policy_document" "assume_role" {  
  statement {
    effect        = "Allow"
    actions       = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::626007623524:root"]
     
    }
  }   
}

resource  "aws_iam_role" "jenkins_role" {  
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name            = "jenkins-labs-s3"
  description     = "jenkins-labs-s3 role"
  force_detach_policies = false
  managed_policy_arns   = [
    "arn:aws:iam::626007623524:policy/jenkins-labs-s3-policy",]
  max_session_duration  = 28800
  path                  = "/"
  tags = var.tags
}