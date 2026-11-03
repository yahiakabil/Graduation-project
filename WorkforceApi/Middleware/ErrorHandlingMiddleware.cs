using System.Text.Json;

namespace WorkforceApi.Middleware;

/// <summary>
/// Global error handler — returns structured JSON errors instead of HTML exception pages.
/// </summary>
public class ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception for {Method} {Path}", context.Request.Method, context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        int statusCode = ex switch
        {
            UnauthorizedAccessException => 401,
            KeyNotFoundException => 404,
            InvalidOperationException => 400,
            ArgumentException => 400,
            _ => 500
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;

        var innerMsg = ex.InnerException != null ? $" -> {ex.InnerException.Message}" : "";
        var response = new
        {
            success = false,
            message = $"{ex.Message}{innerMsg}",
            statusCode
        };

        return context.Response.WriteAsync(JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        }));
    }
}
