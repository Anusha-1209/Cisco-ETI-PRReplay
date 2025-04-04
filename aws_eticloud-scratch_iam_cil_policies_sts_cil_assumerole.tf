resource "aws_iam_policy" "sts_cil_assumerole" {
  name = "sts_cil_assumerole"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "sts:AssumeRole"
          Effect   = "Allow"
          Resource = "arn:aws:iam::380642323071:role/cil"
          Sid      = "VisualEditor0"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags      = var.tags
  tags_all  = {}
}