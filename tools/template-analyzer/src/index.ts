/**
 * Template Analyzer - Main Entry Point
 */

export { TemplateAnalyzer } from './analyzer.js';
export { StrapiSchemaGenerator } from './schema-generator.js';
export { ImplementationPromptGenerator } from './prompt-generator.js';
export { AnthropicClient } from './anthropic-client.js';

export type {
  TemplateAnalysis,
  Section,
  Component,
  Field,
  ContentType,
  Relation,
  ImplementationPrompt,
  AnalyzerConfig,
  AnalyzeOptions,
  GenerateSchemaOptions,
  GenerateImplementationPromptOptions,
} from './types/index.js';
