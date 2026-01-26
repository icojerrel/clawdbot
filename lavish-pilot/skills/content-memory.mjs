/**
 * Content Memory Skill - Lavish Nederland
 * 
 * Provides memory functions for content tracking and duplicate prevention
 * Used by all agents before creating/publishing content
 */

import { execSync } from 'child_process';
import { readFileSync, existsSync } from 'fs';

export const meta = {
  name: 'content-memory',
  description: 'Check content history and prevent duplicates before posting'
};

/**
 * Check if theme was recently used on platform
 */
export function checkDuplicate(platform, theme, thresholdDays = 7) {
  try {
    const result = execSync(
      `/root/.lavish-pilot/scripts/check-duplicate.sh "${platform}" "${theme}" ${thresholdDays}`,
      { encoding: 'utf8' }
    );
    
    return {
      safe: true,
      message: result,
      recommendation: 'Safe to post - theme not recently used'
    };
  } catch (error) {
    // Exit code 1 = duplicate warning
    return {
      safe: false,
      message: error.stdout || error.message,
      recommendation: 'Choose different theme or wait longer'
    };
  }
}

/**
 * Log published content to memory
 */
export function logContent(platform, type, theme, url, agent = 'unknown') {
  try {
    const result = execSync(
      `/root/.lavish-pilot/scripts/log-content.sh "${platform}" "${type}" "${theme}" "${url}" "${agent}"`,
      { encoding: 'utf8' }
    );
    
    return {
      success: true,
      message: result
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

/**
 * Get agent's own content history
 */
export function getAgentHistory(agentName) {
  const contextFile = `/root/.lavish-pilot/memory/agent-context/${agentName}.json`;
  
  if (!existsSync(contextFile)) {
    return {
      success: false,
      error: `No context file found for agent: ${agentName}`
    };
  }
  
  try {
    const context = JSON.parse(readFileSync(contextFile, 'utf8'));
    return {
      success: true,
      context: context,
      recentPosts: context.recent_posts || [],
      themesUsed: context.content_themes_used || {},
      successfulPatterns: context.successful_patterns || [],
      avoidPatterns: context.avoid_patterns || []
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

/**
 * Get underused themes (for content planning)
 */
export function getUnderusedThemes(agentName) {
  const history = getAgentHistory(agentName);
  
  if (!history.success) {
    return history;
  }
  
  const themesUsed = history.themesUsed;
  const allThemes = [
    'weekend-vibes',
    'mixology-tutorial', 
    'behind-the-scenes',
    'festival-prep',
    'customer-story',
    'product-spotlight',
    'recipe-tutorial',
    'party-tips',
    'bartender-secrets',
    'cocktail-hacks'
  ];
  
  // Find themes with 0-2 uses
  const underused = allThemes
    .filter(theme => (themesUsed[theme] || 0) < 3)
    .sort((a, b) => (themesUsed[a] || 0) - (themesUsed[b] || 0));
  
  return {
    success: true,
    underusedThemes: underused,
    themeCounts: themesUsed
  };
}

/**
 * Test function (demo mode)
 */
export async function run(context, params = {}) {
  const { action = 'check', platform, theme, agent } = params;
  
  console.log('🧠 Content Memory Skill - Lavish Nederland');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  
  switch (action) {
    case 'check':
      console.log(`✓ Checking duplicate: ${theme} on ${platform}`);
      const check = checkDuplicate(platform || 'instagram', theme || 'test-theme');
      console.log(check.safe ? '✅ Safe to post' : '⚠️  Duplicate warning');
      return check;
      
    case 'underused':
      console.log(`✓ Finding underused themes for: ${agent || 'social-manager'}`);
      const underused = getUnderusedThemes(agent || 'social-manager');
      if (underused.success) {
        console.log('Underused themes:', underused.underusedThemes.slice(0, 5).join(', '));
      }
      return underused;
      
    default:
      console.log('📖 Content Memory Skill Usage:\n');
      console.log('Actions:');
      console.log('  - check: {action: "check", platform: "instagram", theme: "weekend-vibes"}');
      console.log('  - underused: {action: "underused", agent: "social-manager"}');
      return { info: 'See console for usage' };
  }
}
