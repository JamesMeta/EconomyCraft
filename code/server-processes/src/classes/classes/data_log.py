from collections import Counter
from typing import Optional, Iterable, Any

from classes.subAi.t_user import T_user



# Optional dependencies for nicer output and charts
try:
    from rich.console import Console
    from rich.table import Table
except Exception:  # pragma: no cover - best-effort import
    Console = None  # type: ignore
    Table = None  # type: ignore

try:
    import matplotlib.pyplot as plt
except Exception:  # pragma: no cover - best-effort import
    plt = None  # type: ignore

import os

class DataLog:
    
    def __init__(self) -> None:
        
        # {company_name: {category: score}}
        self.company_share_category_scores_all_users_total: dict[str, dict[str,float]] = {}
        
        # {ai_name: {company_name: {category: score}}}
        self.company_share_category_scores_by_user_type: dict[str, dict[str, dict[str, float]]] = {}
        
        # {ai_history_scope_in_days: {company_name: {category: score}}}
        self.company_share_category_scores_by_history_scope: dict[int, dict[str, dict[str, float]]] = {}
        
        # {company_name: number_of_wins}
        self.company_share_score_wins_all_users_total: dict[str, int] = {}
        
        # {ai_name: {company_name: number_of_wins}}
        self.company_share_score_wins_by_user_type: dict[str, dict[str, int]] = {}
        
        # {ai_history_scope_in_days: {company_name: number_of_wins}}
        self.company_share_score_wins_by_history_scope: dict[int, dict[str, int]] = {}
        
        self.score_data_collected = False
        self.win_data_collected = False
        
        self.user_type_counter: dict[str, int] = {}
        self.history_scope_counter: dict[int, int] = {}
        
 
    
    def count_user(self, user: T_user):
        user_type = user.name
        history_scope = user.history_scope
        
        if user_type in self.user_type_counter:
            self.user_type_counter[user_type] += 1
        
        else:
            self.user_type_counter[user_type] = 1
        
        if history_scope in self.history_scope_counter:
            
            self.history_scope_counter[history_scope] += 1
        else:
            self.history_scope_counter[history_scope] = 1
    
    def calculate_averages(self):
        for company_name, item in self.company_share_category_scores_all_users_total.items():
            for category, score in item.items():
                self.company_share_category_scores_all_users_total[company_name][category] = score / sum(self.user_type_counter.values())
        
        for history_scope, company_map in self.company_share_category_scores_by_history_scope.items():
            for company_name, score_map in company_map.items():
                for category, score in score_map.items():
                    self.company_share_category_scores_by_history_scope[history_scope][company_name][category] = score / self.history_scope_counter[history_scope]
                    
        for user_type, company_map in self.company_share_category_scores_by_user_type.items():
            for company_name, score_map in company_map.items():
                for category, score in score_map.items():
                    self.company_share_category_scores_by_user_type[user_type][company_name][category] = score / self.user_type_counter[user_type]
        
    
    def log_users_scores(self, scores: dict[str, float], user: T_user, company_name: str):
        self.add_scores_to_all_users_total_map(scores,company_name)
        self.add_scores_to_scores_map_by_history_scope(scores, company_name, user)
        self.add_scores_to_scores_map_by_user_type(scores, company_name, user)
        
        self.score_data_collected = True
        
        
    def log_users_wins(self, scores: dict[str, float], user: T_user):
        self.add_wins_to_company_share_all_users(scores)
        self.add_wins_to_company_share_by_user_type(scores, user)
        self.add_wins_to_company_share_by_history_scope(scores, user)
        
        self.win_data_collected = True
    
    def print_all_tables(self):
        
        if not self.score_data_collected or not self.win_data_collected:
            raise Exception("Data Logger contains incomplete data")
        
        self.print_company_share_category_scores_all_users_total()
        self.print_company_share_category_scores_by_history_scope()
        self.print_company_share_category_scores_by_user_type()
        self.print_company_share_score_wins_all_users_total()
        self.print_company_share_score_wins_by_history_scope()
        self.print_company_share_score_wins_by_user_type()
    
    def build_all_charts(self):
        
        if not self.score_data_collected or not self.win_data_collected:
            raise Exception("Data Logger contains incomplete data")
        
        self.chart_company_share_category_scores_all_users_total(filename="charts/category-scores-all-users")
        self.chart_company_share_category_scores_by_history_scope(filename="charts/category-scores-history-scope")
        self.chart_company_share_category_scores_by_user_type(filename="charts/category-scores-by-users")
        self.chart_company_share_score_wins_all_users_total(filename="charts/share-wins-all-users")
        self.chart_company_share_score_wins_by_history_scope(filename="charts/share-wins-by-history-scope")
        self.chart_company_share_score_wins_by_user_type(filename="charts/share-wins-by-users")
    

    
    def add_scores_to_score_map(self, score_map: dict[str, float], scores: dict[str,float]) -> dict[str,float]:
        
        combined: dict[str, float] = {
            k: score_map.get(k, 0) + scores.get(k, 0)
            for k in set(score_map) | set(scores)
        }
        
        return combined
    
    def add_wins_to_win_map(self, score_map: dict[str, int], winning_company_name: str) -> None:
        
        if winning_company_name in score_map:
            score_map[winning_company_name] += 1
        else:
            score_map[winning_company_name] = 1
        
        
    
    def add_scores_to_all_users_total_map(self, scores: dict[str, float], company_name: str) -> None:
        if company_name in self.company_share_category_scores_all_users_total:
            score_map = self.company_share_category_scores_all_users_total[company_name]
            self.company_share_category_scores_all_users_total[company_name] = self.add_scores_to_score_map(score_map, scores)
        else:
            self.company_share_category_scores_all_users_total[company_name] = scores
        
    def add_scores_to_scores_map_by_user_type(self, scores: dict[str, float], company_name: str, user: T_user) -> None:
        user_type = user.name
        
        if user_type in self.company_share_category_scores_by_user_type:
            score_map_user = self.company_share_category_scores_by_user_type[user_type]
            
            if company_name in score_map_user:
                score_map = score_map_user[company_name]
                score_map_user[company_name] = self.add_scores_to_score_map(score_map, scores)
            
            else:
                score_map_user[company_name] = scores
        
        else:
            self.company_share_category_scores_by_user_type[user_type] = {}
            self.company_share_category_scores_by_user_type[user_type][company_name] = scores
    
    def add_scores_to_scores_map_by_history_scope(self, scores: dict[str, float], company_name: str, user: T_user) -> None:
        user_type = user.history_scope
        
        if user_type in self.company_share_category_scores_by_history_scope:
            score_map_user = self.company_share_category_scores_by_history_scope[user_type]
            
            if company_name in score_map_user:
                score_map = score_map_user[company_name]
                score_map_user[company_name] = self.add_scores_to_score_map(score_map, scores)
            
            else:
                score_map_user[company_name] = scores
        
        else:
            self.company_share_category_scores_by_history_scope[user_type] = {}
            self.company_share_category_scores_by_history_scope[user_type][company_name] = scores
    
    def add_wins_to_company_share_all_users(self, scores: dict[str, float]):
        # pick the company id with the highest score
        winning_company = max(scores, key=lambda k: scores[k])
        winners_map = self.company_share_score_wins_all_users_total
        self.add_wins_to_win_map(winners_map,  winning_company)
    
    def add_wins_to_company_share_by_user_type(self, scores: dict[str, float], user: T_user) -> None:
        winning_company = max(scores, key=lambda k: scores[k])
        user_type = user.name
        
        if user_type in self.company_share_score_wins_by_user_type:
            winners_map = self.company_share_score_wins_by_user_type[user_type]
        else:
            self.company_share_score_wins_by_user_type[user_type] = {}
            winners_map = self.company_share_score_wins_by_user_type[user_type]
        
        self.add_wins_to_win_map(winners_map, winning_company)
        
    def add_wins_to_company_share_by_history_scope(self, scores: dict[str, float], user: T_user) -> None:
        winning_company = max(scores, key=lambda k: scores[k])
        user_type = user.history_scope
        if user_type in self.company_share_score_wins_by_history_scope:
            winners_map = self.company_share_score_wins_by_history_scope[user_type]
        else:
            self.company_share_score_wins_by_history_scope[user_type] = {}
            winners_map = self.company_share_score_wins_by_history_scope[user_type]
        self.add_wins_to_win_map(winners_map, winning_company)
        
    # ----------------------
    # Pretty printers (rich)
    # ----------------------
    def _get_console(self, console: Optional[Any] = None) -> Any:
        if console is not None:
            return console
        if Console is None:
            raise ImportError("rich is required for pretty printing. Install with `pip install rich`.")
        return Console()

    def _categories_union(self, maps: Iterable[dict]) -> list:
        """Return sorted union of category keys from iterable of {category: value} maps."""
        cats: set[str] = set()
        for m in maps:
            if isinstance(m, dict):
                cats.update(m.keys())
        return sorted(cats)

    def print_company_share_category_scores_all_users_total(self, console: Optional[object] = None) -> None:
        """Print `company_share_category_scores_all_users_total` as a table.

        Structure: {company_name: {category: score}}
        """
        cons = self._get_console(console)
        if not self.company_share_category_scores_all_users_total:
            cons.print("[bold yellow]No company share category scores (all users total) to display.[/]")
            return

        companies = sorted(self.company_share_category_scores_all_users_total.keys())
        all_cats = self._categories_union(self.company_share_category_scores_all_users_total.values())

        table = Table(title="Company share category scores (all users)")
        table.add_column("Company ID", style="bold cyan")
        for c in all_cats:
            table.add_column(str(c), justify="right")

        for cid in companies:
            row = [str(cid)]
            catmap = self.company_share_category_scores_all_users_total.get(cid, {})
            for c in all_cats:
                val = catmap.get(c, 0)
                row.append(f"{val:.5f}")
            table.add_row(*row)

        cons.print(table)

    def print_company_share_category_scores_by_user_type(self, console: Optional[object] = None) -> None:
        """Print `company_share_category_scores_by_user_type`.

        Structure: {ai_name: {company_name: {category: score}}}
        """
        cons = self._get_console(console)
        if not self.company_share_category_scores_by_user_type:
            cons.print("[bold yellow]No company share category scores by user type to display.[/]")
            return

        for user_type, compmap in self.company_share_category_scores_by_user_type.items():
            cons.print(f"\n[bold underline]User type:[/] {user_type}")
            if not compmap:
                cons.print("  (no data)")
                continue
            all_cats = self._categories_union(compmap.values())
            table = Table()
            table.add_column("Company ID", style="bold cyan")
            for c in all_cats:
                table.add_column(str(c), justify="right")

            for cid in sorted(compmap.keys()):
                row = [str(cid)]
                catmap = compmap.get(cid, {})
                for c in all_cats:
                    row.append(f"{catmap.get(c,0):.5f}")
                table.add_row(*row)

            cons.print(table)

    def print_company_share_category_scores_by_history_scope(self, console: Optional[object] = None) -> None:
        """Print `company_share_category_scores_by_history_scope`.

        Structure: {ai_history_scope_in_days: {company_name: {category: score}}}
        """
        cons = self._get_console(console)
        if not self.company_share_category_scores_by_history_scope:
            cons.print("[bold yellow]No company share category scores by history scope to display.[/]")
            return

        for scope, compmap in self.company_share_category_scores_by_history_scope.items():
            cons.print(f"\n[bold underline]History scope (days):[/] {scope}")
            if not compmap:
                cons.print("  (no data)")
                continue
            all_cats = self._categories_union(compmap.values())
            table = Table()
            table.add_column("Company ID", style="bold cyan")
            for c in all_cats:
                table.add_column(str(c), justify="right")

            for cid in sorted(compmap.keys()):
                row = [str(cid)]
                catmap = compmap.get(cid, {})
                for c in all_cats:
                    row.append(f"{catmap.get(c,0):.5f}")
                table.add_row(*row)

            cons.print(table)

    def print_company_share_score_wins_all_users_total(self, console: Optional[object] = None) -> None:
        """Print `company_share_score_wins_all_users_total`.

        Structure: {company_name: number_of_wins}
        """
        cons = self._get_console(console)
        if not self.company_share_score_wins_all_users_total:
            cons.print("[bold yellow]No company share wins (all users) to display.[/]")
            return

        table = Table(title="Company share wins (all users)")
        table.add_column("Company ID", style="bold cyan")
        table.add_column("Wins", justify="right")

        for cid, wins in sorted(self.company_share_score_wins_all_users_total.items(), key=lambda x: -x[1]):
            table.add_row(str(cid), str(wins))

        cons.print(table)

    def print_company_share_score_wins_by_user_type(self, console: Optional[object] = None) -> None:
        """Print `company_share_score_wins_by_user_type`.

        Structure: {ai_name: {company_name: number_of_wins}}
        """
        cons = self._get_console(console)
        if not self.company_share_score_wins_by_user_type:
            cons.print("[bold yellow]No company share wins by user type to display.[/]")
            return

        for user_type, winsmap in self.company_share_score_wins_by_user_type.items():
            cons.print(f"\n[bold underline]User type:[/] {user_type}")
            if not winsmap:
                cons.print("  (no data)")
                continue
            table = Table()
            table.add_column("Company ID", style="bold cyan")
            table.add_column("Wins", justify="right")
            for cid, wins in sorted(winsmap.items(), key=lambda x: -x[1]):
                table.add_row(str(cid), str(wins))
            cons.print(table)

    def print_company_share_score_wins_by_history_scope(self, console: Optional[object] = None) -> None:
        """Print `company_share_score_wins_by_history_scope`.

        Structure: {ai_history_scope_in_days: {company_name: number_of_wins}}
        """
        cons = self._get_console(console)
        if not self.company_share_score_wins_by_history_scope:
            cons.print("[bold yellow]No company share wins by history scope to display.[/]")
            return

        for scope, winsmap in self.company_share_score_wins_by_history_scope.items():
            cons.print(f"\n[bold underline]History scope (days):[/] {scope}")
            if not winsmap:
                cons.print("  (no data)")
                continue
            table = Table()
            table.add_column("Company ID", style="bold cyan")
            table.add_column("Wins", justify="right")
            for cid, wins in sorted(winsmap.items(), key=lambda x: -x[1]):
                table.add_row(str(cid), str(wins))
            cons.print(table)

    # ----------------------
    # Charting functions (matplotlib)
    # ----------------------
    def _ensure_plt(self):
        if plt is None:
            raise ImportError("matplotlib is required for charting. Install with `pip install matplotlib`.")

    def chart_company_share_category_scores_all_users_total(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Create a grouped bar chart for categories vs companies for all users total.

        - filename: if provided, saves the figure to that path.
        - show: if True, will attempt to show the plot (may not work on headless systems).
        """
        self._ensure_plt()
        if not self.company_share_category_scores_all_users_total:
            return

        all_cats = self._categories_union(self.company_share_category_scores_all_users_total.values())
        companies = sorted(self.company_share_category_scores_all_users_total.keys())

        x = range(len(all_cats))
        width = 0.8 / max(1, len(companies))

        fig, ax = plt.subplots(figsize=(max(6, len(all_cats)), 4 + len(companies) * 0.3))
        for i, cid in enumerate(companies):
            vals = [self.company_share_category_scores_all_users_total[cid].get(cat, 0) for cat in all_cats]
            ax.bar([xi + i * width for xi in x], vals, width=width, label=str(cid))

        ax.set_xticks([xi + width * (len(companies) - 1) / 2 for xi in x])
        ax.set_xticklabels(all_cats, rotation=45, ha="right")
        ax.set_ylabel("Score")
        ax.set_title("Company category scores (all users)")
        ax.legend(title="Company ID", bbox_to_anchor=(1.02, 1), loc="upper left")
        fig.tight_layout()

        if filename:
            os.makedirs(os.path.dirname(filename), exist_ok=True)
            fig.savefig(filename)
            
        if show:
            plt.show()
        plt.close(fig)

    def chart_company_share_category_scores_by_user_type(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Create charts per user type; each chart is a grouped bar chart of categories vs companies."""
        self._ensure_plt()
        if not self.company_share_category_scores_by_user_type:
            return

        # If filename provided and multiple user types, append typename to filename
        for user_type, compmap in self.company_share_category_scores_by_user_type.items():
            if not compmap:
                continue
            all_cats = self._categories_union(compmap.values())
            companies = sorted(compmap.keys())
            x = range(len(all_cats))
            width = 0.8 / max(1, len(companies))

            fig, ax = plt.subplots(figsize=(max(6, len(all_cats)), 4 + len(companies) * 0.3))
            for i, cid in enumerate(companies):
                vals = [compmap[cid].get(cat, 0) for cat in all_cats]
                ax.bar([xi + i * width for xi in x], vals, width=width, label=str(cid))

            ax.set_xticks([xi + width * (len(companies) - 1) / 2 for xi in x])
            ax.set_xticklabels(all_cats, rotation=45, ha="right")
            ax.set_ylabel("Score")
            ax.set_title(f"Company category scores — user type: {user_type}")
            ax.legend(title="Company ID", bbox_to_anchor=(1.02, 1), loc="upper left")
            fig.tight_layout()

            if filename:
                os.makedirs(os.path.dirname(filename + "-" + str(user_type)), exist_ok=True)
                fig.savefig(filename + "-" + str(user_type))
            if show:
                plt.show()
            plt.close(fig)

    def chart_company_share_category_scores_by_history_scope(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Create charts per history scope.

        Structure: {history_scope: {company_name: {category: score}}}
        """
        self._ensure_plt()
        if not self.company_share_category_scores_by_history_scope:
            return

        for scope, compmap in self.company_share_category_scores_by_history_scope.items():
            if not compmap:
                continue
            all_cats = self._categories_union(compmap.values())
            companies = sorted(compmap.keys())
            x = range(len(all_cats))
            width = 0.8 / max(1, len(companies))

            fig, ax = plt.subplots(figsize=(max(6, len(all_cats)), 4 + len(companies) * 0.3))
            for i, cid in enumerate(companies):
                vals = [compmap[cid].get(cat, 0) for cat in all_cats]
                ax.bar([xi + i * width for xi in x], vals, width=width, label=str(cid))

            ax.set_xticks([xi + width * (len(companies) - 1) / 2 for xi in x])
            ax.set_xticklabels(all_cats, rotation=45, ha="right")
            ax.set_ylabel("Score")
            ax.set_title(f"Company category scores — history scope: {scope} days")
            ax.legend(title="Company ID", bbox_to_anchor=(1.02, 1), loc="upper left")
            fig.tight_layout()

            out = None
            if filename:
                os.makedirs(os.path.dirname(filename + "-" + str(scope)), exist_ok=True)
                fig.savefig(filename + "-" + str(scope))
            if show:
                plt.show()
            plt.close(fig)

    def chart_company_share_score_wins_all_users_total(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Bar chart of company wins (all users)."""
        self._ensure_plt()
        if not self.company_share_score_wins_all_users_total:
            return

        items = sorted(self.company_share_score_wins_all_users_total.items(), key=lambda x: -x[1])
        labels = [str(i[0]) for i in items]
        vals = [i[1] for i in items]

        fig, ax = plt.subplots(figsize=(max(6, len(labels) * 0.6), 4))
        ax.bar(labels, vals, color="#2b8cbe")
        ax.set_xlabel("Company ID")
        ax.set_ylabel("Wins")
        ax.set_title("Company wins (all users)")
        for i, v in enumerate(vals):
            ax.text(i, v + max(vals) * 0.01 if max(vals) else v, str(v), ha='center', va='bottom')
        fig.tight_layout()
        if filename:
            os.makedirs(os.path.dirname(filename), exist_ok=True)
            fig.savefig(filename)
        if show:
            plt.show()
        plt.close(fig)

    def chart_company_share_score_wins_by_user_type(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Create a chart per user type for wins."""
        self._ensure_plt()
        if not self.company_share_score_wins_by_user_type:
            return

        for user_type, winsmap in self.company_share_score_wins_by_user_type.items():
            if not winsmap:
                continue
            items = sorted(winsmap.items(), key=lambda x: -x[1])
            labels = [str(i[0]) for i in items]
            vals = [i[1] for i in items]
            fig, ax = plt.subplots(figsize=(max(6, len(labels) * 0.6), 4))
            ax.bar(labels, vals)
            ax.set_xlabel("Company ID")
            ax.set_ylabel("Wins")
            ax.set_title(f"Company wins — user type: {user_type}")
            fig.tight_layout()
            out = None
            if filename:
                os.makedirs(os.path.dirname(filename + "-" + str(user_type)), exist_ok=True)
                fig.savefig(filename + "-" + str(user_type))
            if show:
                plt.show()
            plt.close(fig)

    def chart_company_share_score_wins_by_history_scope(self, filename: Optional[str] = None, show: bool = False) -> None:
        """Create a chart per history scope for wins."""
        self._ensure_plt()
        if not self.company_share_score_wins_by_history_scope:
            return

        for scope, winsmap in self.company_share_score_wins_by_history_scope.items():
            if not winsmap:
                continue
            items = sorted(winsmap.items(), key=lambda x: -x[1])
            labels = [str(i[0]) for i in items]
            vals = [i[1] for i in items]
            fig, ax = plt.subplots(figsize=(max(6, len(labels) * 0.6), 4))
            ax.bar(labels, vals)
            ax.set_xlabel("Company ID")
            ax.set_ylabel("Wins")
            ax.set_title(f"Company wins — history scope: {scope} days")
            fig.tight_layout()
            out = None
            if filename:
                os.makedirs(os.path.dirname(filename + "-" + str(scope)), exist_ok=True)
                fig.savefig(filename + "-" + str(scope))
            if show:
                plt.show()
            plt.close(fig)
        